package controllers

import play.api.Play.current
import play.api.db.DB
import play.api._
import play.api.mvc._
import anorm._
import play.api.cache._
import play.api.libs.json.Json
import play.api.libs.json.Json._

object Routing extends Controller {
  def route(lat: String, long: String) = Action { //Cached(req => "geo")
    def radius = math.floor(5500 / 3600) * 15 * 60
    def parseDouble(s: String) = try Some(s.toDouble) catch { case _ => 0 }

    class Point(long: Double, lat: Double) {
      def this(inputLong: String, inputLat: String) = this(inputLong.toDouble, inputLat.toDouble)
      def this(input: Seq[Double]) = this(input(0), input(1))
      //      def long = parseDouble(inputLong)
      //      def lat = parseDouble(inputLat)
      override def toString = "POINT(" + long + " " + lat + ")"
    }
    //abstract class NodePoint
    class Node(id: Long, p: Point) {}
    class Road(id: Long, points: List[Point], nodes: List[Long]) {}
    class RoadPoint(in_road_id: Long, in_point: Point) {
      def road_id = in_road_id
      def point = in_point
      
    }

    def center = new Point(lat, long)

    DB.withConnection("osm") { implicit c =>

      /**
       * Verkrijg de afstand tussen 2 punten
       */
      def cost(point1: Point, point2: Point): Double =
        SQL("""
    	    select
    			ST_Length(ST_Line_Substring(linestring, 
    				ST_Line_Locate_Point(linestring, {point1}),
    				ST_Line_Locate_Point(linestring, {point2}))) as length
    	    from ways
    	    where foot and ST_Contains(linestring, {point1}) and ST_Contains(linestring, {point2}) 
    	    order by ST_Length(linestring) desc limit 1
          """).on("point1" -> point1.toString, "point2" -> point2.toString)().head[Double]("length")

      def costNodes(point1: Node, point2: Node): Double =
        SQL("""
    	    select
    			ST_Length(ST_Line_Substring(linestring, 
    				ST_Line_Locate_Point(linestring, (select geom from nodes where id = {node1} limit 1),
    				ST_Line_Locate_Point(linestring, (select geom from nodes where id = {node2} limit 1)))) as length
    	    from ways
    	    where foot and ARRAY[{node1}, {node2}] @> nodes
    	    order by length asc limit 1
          """).on("node1" -> point1, "node2" -> point2)().head[Double]("length")
      /**
       * Verkrijg alle wegen in de cirkel
       */
      val roads = SQL("""
    	    select id, array_to_string(nodes, ',') as nodes,
    		  ST_AsGeoJSON(
    			ST_Intersection(linestring, ST_Buffer(ST_GeographyFromText({point}),{radius}))
    	    , 7) as geometry,
    			ST_Distance(linestring, ST_GeographyFromText({point})) as distance
    	    from ways
    	    where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring)
    	    order by distance asc limit 1000;
          """).on("point" -> center.toString, "radius" -> radius)().toList.map({ t =>
        val json = Json.parse(t[String]("geometry"))
        val points = (json \ "coordinates").as[List[Seq[Double]]].map({ c => new Point(c) })
        val nodes = t[String]("nodes").split(',').map(_.toLong).toList
        val id = t[Long]("id")
        id -> new Road(id, points, nodes)
      }).toMap

      /**
       * Zoek een punt op de weg wat het meest dichtbij het center is.
       */
      val centerRoadPoint = {
        def t = SQL("""
          select id,
          ST_AsGeoJSON(ST_Line_Interpolate_Point(linestring, ST_Line_Locate_Point(linestring, ST_GeographyFromText({point})::Geometry))) as geometry
          from ways
          where foot
          order by ST_Distance(linestring, ST_GeographyFromText({point})) asc limit 1 
          """).on("point" -> center.toString)().head
        val json = Json.parse(t[String]("geometry"))
        val point = new Point((json \ "coordinates").as[Seq[Double]])
        new RoadPoint(t[Long]{"id"}, point)
      }

      /**
       * Verkrijg alle nodes in de cirkel
       */
      val intersection = SQL("""
			select
    		  nodes.id as id,
    		  ST_AsGeoJSON(nodes.geom) as geometry
			from ways
			join way_nodes on ways.id = way_nodes.way_id
			join nodes on way_nodes.node_id = nodes.id
			where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring) and
			ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), nodes.geom) and
			(select count(way_id) from way_nodes where node_id = nodes.id) > 1
          """).on("point" -> center.toString, "radius" -> radius)().toList.map({ t =>
        val json = Json.parse(t[String]("geometry"))
        val point = new Point((json \ "coordinates").as[Seq[Double]])
        val id = t[Long]("id")
        id -> new Node(id, point)
      }).toMap

      /**
       * Verkrijg alle punten op de rand van de cirkel.
       * Hiervan nodes maken
       */
      val endNodes = SQL("""
  with nearby_ways as (
	  select *
	  from ways
	  where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring))
  select
	  ST_AsGeoJSON(geom) as geometry,
	  (select id FROM nearby_ways order by ST_Distance(linestring, geom) asc limit 1) as way_id
  from (
	  select (ST_DumpPoints(g.geom)).*
	  from
	  (select ST_ConvexHull(ST_Collect(ST_Intersection(linestring::geometry, ST_Buffer(ST_GeographyFromText({point}),{radius})::geometry))) as geom
  from nearby_ways) as g) as j;
          """).on("point" -> center.toString, "radius" -> radius)().toList.map({ t =>
        val json = Json.parse(t[String]("geometry"))
        val point = new Point((json \ "coordinates").as[Seq[Double]])
        val id = t[Long]("way_id")
        id -> new RoadPoint(id, point)
      }).toMap
      
      def beginRoad = roads(centerRoadPoint.road_id)
      
      Ok("Werkt!")
    }
  }
}
    	
    	
////    	Ok(toJson(SQL(
////    	    """
////    	    select ST_AsGeoJSON(
////    			ST_Intersection(linestring, ST_Buffer(ST_GeographyFromText({point}),{radius}))
////    	    , 7) as geometry,
////    			ST_Distance(linestring, ST_GeographyFromText({point})) as distance
////    	    from ways
////    	    where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring)
////    	    order by distance asc limit 1000;
////    	"""
////    	    ).on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
//    	
////    	Ok(toJson(SQL("""
////select ST_AsGeoJSON(nodes.geom) as geometry
////from ways
////join way_nodes on ways.id = way_nodes.way_id
////join nodes on way_nodes.node_id = nodes.id
////where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring) and
////ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), nodes.geom) and
////(select count(way_id) from way_nodes where node_id = nodes.id) > 1
////    	""").on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
//    	    
////    	WITH nearby_ways AS (SELECT * FROM ways WHERE foot and ST_Intersects(ST_Buffer(ST_GeographyFromText('POINT(5.974545478820801 51.979937410940316)'),900.0), linestring))
////SELECT geom,
////(SELECT id FROM nearby_ways order by ST_Distance(linestring, geom) asc limit 1) as way_id
////FROM (
////  SELECT (ST_DumpPoints(g.geom)).*
////  FROM
////  (select
////ST_ConvexHull(ST_Collect(ST_Intersection(linestring::geometry, ST_Buffer(ST_GeographyFromText('POINT(5.974545478820801 51.979937410940316)'),900.0)::geometry))) as geom
////from nearby_ways) as g) as j;
//    	
////    	Ok(toJson(SQL("""
////select 
////ST_AsText(
////    	    ST_DumpPoints(ST_ConvexHull(
////    	    ST_Collect(
////    	    ST_Intersection(
////    	    linestring::geometry,
////    	    ST_Buffer(ST_GeographyFromText({point}),{radius})::geometry))))) as geometry
////from ways
////where foot and
////ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring)
////    	""").on("point" -> point(long, lat), "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))//group by id
//    	
////    	Ok(toJson(SQL("""
////    	    WITH nearby_ways AS (SELECT * FROM ways WHERE foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring))
////SELECT geom,
////(SELECT id FROM nearby_ways order by ST_Distance(linestring, geom) asc limit 1) as way_id
////FROM (
////  SELECT (ST_DumpPoints(g.geom)).*
////  FROM
////  (select
////ST_ConvexHull(ST_Collect(ST_Intersection(linestring::geometry, ST_Buffer(ST_GeographyFromText({point}),{radius})::geometry))) as geom
////from nearby_ways) as g) as j;
////    	    """).on("point" -> point(long, lat), "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
//    }
//  }
//}