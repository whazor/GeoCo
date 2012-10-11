package controllers

import play.api.Play.current
import play.api.db.DB
import play.api.mvc._
import anorm._
import play.api.libs.json.Json._
import play.api.libs.json._

object Routing extends Controller {
  def route(lat: String, long: String) = Action {
    DB.withConnection("OSM") { implicit c =>
      def radius = math.floor(5500 / 3600) * 15 * 60

      object LatLng {
        def apply(inputLong: String, inputLat: String): LatLng = LatLng(inputLong.toDouble, inputLat.toDouble)
        def apply(input: Seq[Double]):LatLng = LatLng(input(0), input(1))
        def array = Seq(long, lat)
        override def toString = "POINT(" + long + " " + lat + ")"
      }
      case class LatLng(long: Double, lat: Double)
      def center = LatLng(lat, long)

      case class Edge(node1: Long, node2: Long, distance: BigDecimal)

      def edgesInGeom(geom: String) =
      SQL("""
      with intersections as (
      select way_nodes.*, nodes.geom as geom, ways.linestring as linestring
      from way_nodes
      join nodes on way_nodes.node_id = nodes.id and ST_Intersects(nodes.geom, {geom})
      join ways on ways.id = way_nodes.way_id and ST_Intersects(ways.linestring, {geom}) and ways.foot
      where (select count(*) from way_nodes where way_nodes.node_id = nodes.id group by way_nodes.node_id) > 1)
      select
      w1.node_id as node_1,
      w2.node_id as node_2,
      w1.way_id as way,
      ST_Line_Substring(w1.linestring,
      LEAST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom)),
      GREATEST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom))
      )::Geography as line,
      ST_Length(ST_Line_Substring(w1.linestring,
        LEAST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom)),
        GREATEST(ST_Line_Locate_Point(w1.linestring, w1.geom), ST_Line_Locate_Point(w1.linestring, w2.geom))
      )::Geography)::numeric as distance
      from intersections w1
      join intersections w2 on w1.way_id = w2.way_id and w1.node_id != w2.node_id
      where @(w1.sequence_id - w2.sequence_id) = 1
          """.stripMargin).on("geom" -> geom)().toList.map({ t =>
        //order by ST_Distance(w1.linestring, ST_GeomFromText('POINT(5.859330 51.974978)', 4326)) asc
        val node1 = t[Long]("node_1")
        val node2 = t[Long]("node_2")
//        val way = t[Long]("way")
        val distance = BigDecimal(t[java.math.BigDecimal]("distance"))
        Edge(node1, node2, distance)
      }).toList
      def edgesInBB(lb: LatLng, ro: LatLng) = edgesInGeom("ST_MakeEnvelope("+lb.long+", "+lb.lat+", "+ro.long+", "+ro.lat+", 4326)")
      def edgesInRadius(center:LatLng, radius:Double) =
        edgesInGeom("ST_Buffer(ST_GeomFromText(\""+center+"\"), "+radius+")")

      def nodeNearestTo(loc:LatLng): Long =
        SQL(
          """
            select id
            from nodes
            where (select count(*) from way_nodes where way_nodes.node_id = nodes.id group by way_nodes.node_id) > 1
            order by geom <-> ST_GeomFromText({POINT}, 4326) limit 1;
          """.stripMargin).on('point -> loc)().head[Long]("id")
//      }

      Ok("werkt")
    }
  }
}