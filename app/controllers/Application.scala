package controllers

import play.api.Play.current
import play.api.db.DB
import play.api._
import play.api.mvc._
import anorm._
//import play.api.cache._
import play.api.libs.json.Json
import play.api.libs.json.Json._

object Application extends Controller {
  
  def index = Action {
    Ok(views.html.index("Your new application is ready."))
  }
  
  def geo(lat: String, long: String) = Action {//Cached(req => "geo")
    def parseDouble(s: String) = try { Some(s.toDouble) } catch { case _ => 0 }
    DB.withConnection("osm") { implicit c =>
    	def point:String = "POINT("+long.toDouble.toString()+" "+lat.toDouble.toString+")"
    	
    	def radius = math.floor((5500 / 3600) * 15 * 60)
    	Ok(toJson(SQL(
    	    """
    	    select ST_AsGeoJSON(
    			ST_Intersection(linestring, ST_Buffer(ST_GeographyFromText({point}),{radius}))
    	    , 7) as geometry,
    			ST_Distance(linestring, ST_GeographyFromText({point})) as distance
    	    from ways
    	    where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring)
    	    order by distance asc limit 1000;
    	"""
    	    ).on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
    	
//    	Ok(toJson(SQL("""
//select ST_AsGeoJSON(nodes.geom) as geometry
//from ways
//join way_nodes on ways.id = way_nodes.way_id
//join nodes on way_nodes.node_id = nodes.id
//where foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring) and
//ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), nodes.geom) and
//(select count(way_id) from way_nodes where node_id = nodes.id) > 1
//    	""").on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
    	    
//    	Ok(toJson(SQL("""
//select 
//ST_AsGeoJSON(ST_ConvexHull(ST_Collect(ST_Intersection(linestring::geometry, ST_Buffer(ST_GeographyFromText({point}),{radius})::geometry)))) as geometry
//from ways
//where foot and
//ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring)
//    	""").on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))//group by id
    	
//    	
//    	Ok(toJson(SQL("""
//    	    WITH nearby_ways AS (SELECT * FROM ways WHERE foot and ST_Intersects(ST_Buffer(ST_GeographyFromText({point}),{radius}), linestring))
//SELECT geom as geometry,
//(SELECT id FROM nearby_ways order by ST_Distance(linestring, geom) asc limit 1) as way_id
//FROM (
//  SELECT (ST_DumpPoints(g.geom)).*
//  FROM
//  (select
//ST_ConvexHull(ST_Collect(ST_Intersection(linestring::geometry, ST_Buffer(ST_GeographyFromText({point}),{radius})::geometry))) as geom
//from nearby_ways) as g) as j;
//    	    """).on("point" -> point, "radius" -> radius)().map({t => Json.parse(t[String]("geometry"))}) toList))
    }
  }
}