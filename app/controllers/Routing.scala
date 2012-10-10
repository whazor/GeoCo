package controllers

import play.api.db.DB
import play.api.mvc._
import anorm._
import play.api.libs.json.Json._
import play.api.libs.json._

object Routing extends Controller {
  def route(lat: String, long: String) = Action {
    DB.withConnection("OSM") { implicit c =>
      def radius = math.floor(5500 / 3600) * 15 * 60

      case class LatLng(long: Double, lat: Double) {
        def this(inputLong: String, inputLat: String) = this(inputLong.toDouble, inputLat.toDouble)
        def this(input: Seq[Double]) = this(input(0), input(1))
        def array = Seq(long, lat)
        override def toString = "POINT(" + long + " " + lat + ")"
      }

      case class Edge(node1: Long, node2: Long, distance: BigDecimal)

      def edgesInGeom(geom: String) =
      SQL("""
      with intersections as (
      select way_nodes.*, nodes.geom as geom, ways.linestring as linestring
      from way_nodes
      join nodes on way_nodes.node_id = nodes.id and nodes.geom && ST_MakeEnvelope(5.829330, 51.934978, 5.980750, 52.008572, 4326)
      join ways on ways.id = way_nodes.way_id and ST_Intersects(ways.linestring, ST_MakeEnvelope(5.829330, 51.934978, 5.980750, 52.008572, 4326)) and ways.foot
      where (select count(*) from way_nodes where way_nodes.node_id = nodes.id group by way_nodes.node_id) > 1)
      select
      w1.node_id as node_1,
      w2.node_id as node_2,
      w1.way_id as way,
      ST_Length(ST_Line_Substring(w1.linestring,
        LEAST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom)),
        GREATEST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom))
      )::Geography)::numeric as distance
      from intersections w1
      join intersections w2 on w1.way_id = w2.way_id and w1.node_id != w2.node_id
      where @(w1.sequence_id - w2.sequence_id) = 1
      """).on("geom" -> geom)().toList.map({ t =>
        val node1 = t[Long]("node_1")
        val node2 = t[Long]("node_2")
//        val way = t[Long]("way")
        val distance = BigDecimal(t[java.math.BigDecimal]("distance"))
        Edge(node1, node2, distance)
      }).toList
      def edgesInBB(lb: LatLng, ro: LatLng) = edgesInGeom("ST_MakeEnvelope("+lb.long+", "+lb.lat+", "+ro.long+", "+ro.lat+", 4326)")
      def edgesInRadius(center:LatLng, radius:Double) =
        edgesInGeom("ST_Buffer(ST_GeomFromText(\""+center+"\"), "+radius+")")

//      def roadsNearestTo(loc:LatLng) : Road = {
//      def t = SQL("""
//	      select id,
//	      ST_AsGeoJSON(ST_Line_Interpolate_Point(linestring, ST_Line_Locate_Point(linestring, ST_GeographyFromText({point})::Geometry))) as geometry
//	      from ways
//	      where foot and ST_DWithin(linestring, ST_GeographyFromText({point}), {distance})
//	      order by ST_Distance(linestring, ST_GeographyFromText({point})) asc limit 1
//                  	      """).on("point" -> center.toString, "distance" -> 100)().head
//      val json = Json.parse(t[String]("geometry"))
//      val point = new Point((json \ "coordinates").as[Seq[Double]])
//      val centerRoadPoint = RoadPoint(t[Long] { "id" }, point)
//      }

    }
  }
}