package controllers

import play.api.Play.current
import play.api.db.DB
import play.api._
import play.api.mvc._
import anorm._
import play.api.cache._
import play.api.libs.json.Json
import play.api.libs.json.Json._
import play.api.libs.json._

object Routing extends Controller {
  def route(lat: String, long: String) = Action { //Cached(req => "geo")
    def radius = math.floor(5500 / 3600) * 15 * 60
    def parseDouble(s: String) = try Some(s.toDouble) catch { case _ => 0 }

    class Point(long: Double, lat: Double) {
      def this(inputLong: String, inputLat: String) = this(inputLong.toDouble, inputLat.toDouble)
      def this(input: Seq[Double]) = this(input(0), input(1))
      //      def long = parseDouble(inputLong)
      //      def lat = parseDouble(inputLat)
      def array = Seq(long, lat)
      override def toString = "POINT(" + long + " " + lat + ")"
    }
    abstract class Node {
    	def point: Point
//    	override def toString = "POINT(" + long + " " + lat + ")"
    }
    
    case class Road(id: Long, points: List[Point], nodes: List[Long])

    case class Intersection(id: Long, point: Point) extends Node
    case class RoadPoint(road_id: Long, point: Point) extends Node

    def center = new Point(lat, long)

    DB.withConnection("osm") { implicit c =>
      /**
       * Zoek een punt op de weg wat het meest dichtbij het center is.
       * dit kan niet sneller zonder indexes of tijdelijke tabellen
       * Snelheid: ~2400ms
       */
      def t = SQL("""
	      select id,
	      ST_AsGeoJSON(ST_Line_Interpolate_Point(linestring, ST_Line_Locate_Point(linestring, ST_GeographyFromText({point})::Geometry))) as geometry
	      from ways
	      where foot and ST_DWithin(linestring, ST_GeographyFromText({point}), {distance})
	      order by ST_Distance(linestring, ST_GeographyFromText({point})) asc limit 1 
	      """).on("point" -> center.toString, "distance" -> 100)().head
      val json = Json.parse(t[String]("geometry"))
      val point = new Point((json \ "coordinates").as[Seq[Double]])
      val centerRoadPoint = RoadPoint(t[Long] { "id" }, point)
      

      /**
       * Verkrijg alle nodes in de buurt
       * Snelheid: ~15ms
       */
      def findNodes(point: Node, max_distance: BigDecimal): List[(Intersection, BigDecimal)] = {
        point match {
          case Intersection(id, point) => {
            SQL("""
					with crossing_ways as (
						select way_id
						from way_nodes
						where node_id = {id} group by way_id),
					located_node as (select nodes.geom as geom
						from nodes
						where id = {id} limit 1) 
					select DISTINCT ON (ways.id)
					nodes.id as id,
					ST_AsGeoJSON(nodes.geom) as geometry,
					ST_Length(ST_Line_Substring(ways.linestring,
						(
							with tmp_linestring as (
								SELECT (ST_Line_Locate_Point(ways.linestring, (select geom from located_node limit 1))) as p
								UNION
								SELECT ST_Line_Locate_Point(ways.linestring, nodes.geom) as p
							) select p from tmp_linestring order by p asc limit 1
						),
						(
							with tmp_linestring as (
								SELECT (ST_Line_Locate_Point(ways.linestring, (select geom from located_node limit 1))) as p
								UNION
								SELECT ST_Line_Locate_Point(ways.linestring, nodes.geom) as p
							) select p from tmp_linestring order by p desc limit 1
						)
					))::numeric as distance
					from crossing_ways
					join way_nodes on crossing_ways.way_id = way_nodes.way_id 
					join nodes on way_nodes.node_id = nodes.id 
					join ways on ways.id = crossing_ways.way_id
					where nodes.id != {id} and ways.foot and (select count(*) from way_nodes where way_nodes.node_id = nodes.id group by way_nodes.node_id) > 1
					order by ways.id, distance asc
        		    """).on("id" -> id)().toList.map({ t =>
              val json = Json.parse(t[String]("geometry"))
              val point = new Point((json \ "coordinates").as[Seq[Double]])
              val id = t[Long]("id")
              val distance = BigDecimal(t[java.math.BigDecimal]("distance"))
              (new Intersection(id, point), distance)
            }).toList
            //        	 ("(select geom from nodes where id = {node1} limit 1)", id) 
            //        	 ("ST_GeographyFromText({node1})", point.toString) 
          }
          case RoadPoint(id, point) => {
            SQL("""
				select nodes.id as id,         		    
				ST_AsGeoJSON(nodes.geom) as geometry,         		   
				 (
					ST_Length(
						ST_Line_Substring(
							ways.linestring,
				                        (
				                            with tmp_linestring as (
				                                SELECT (ST_Line_Locate_Point(ways.linestring, ST_GeographyFromText({point})::Geometry)) as p
				                                UNION
				                                SELECT ST_Line_Locate_Point(ways.linestring, nodes.geom) as p
				                            ) select p from tmp_linestring order by p asc limit 1
				                        ),
				                        (
				                            with tmp_linestring as (
				                                SELECT (ST_Line_Locate_Point(ways.linestring, ST_GeographyFromText({point})::Geometry)) as p
				                                UNION
				                                SELECT ST_Line_Locate_Point(ways.linestring, nodes.geom) as p
				                            ) select p from tmp_linestring order by p desc limit 1
				                        )
				                )
				          )
				     )::numeric as distance
				from way_nodes         		   
				join nodes on way_nodes.node_id = nodes.id    
				join ways on ways.id = way_nodes.way_id    	
				where ways.foot and way_id = {id} and (select count(*) from way_nodes where way_nodes.node_id = nodes.id group by way_nodes.node_id) > 1
				order by distance limit 2
        		    """).on(
              "id" -> id,
              "point" -> point.toString,
              "max" -> max_distance)().toList.map({ t =>
                val json = Json.parse(t[String]("geometry"))
                val point = new Point((json \ "coordinates").as[Seq[Double]])
                val id = t[Long]("id")
                val distance = BigDecimal(t[java.math.BigDecimal]("distance"))
                (new Intersection(id, point), distance)
              }).toList
          }
        }
      }

      def findRoute(path: List[Node], max: BigDecimal): List[Node] = {
        // Haal alle vorige nodes weg
        def neighbours = findNodes(path.head, max).filterNot(p => path.map(e => e match {
          case Intersection(id, point) => id
          case _ => 0
        }).contains(p._1.id)).filterNot(p => p._2 > max)
        // Selecteer eerste pad
        if (neighbours.length == 0) path
        else{
          neighbours.head._1 match {
            case Intersection(id, point) => System.out.println(id + " " + max) 
          }
        	
          findRoute(path.::(neighbours.head._1), max - neighbours.head._2)
        }
      }
      def nodes = findRoute(List(centerRoadPoint), 1000).map(f => Json.toJson(f.point.array)).toSeq
      Ok(Json.toJson(
          Map(
    		  "type" -> toJson("Multipoint"),
    		  "geometries" -> JsArray(nodes)
          )
        ))
    }
  }
}
