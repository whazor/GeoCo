package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.db.DB
import play.api.Play.current

import anorm._
import play.api.libs.json.Json
import play.api.libs.json.Json._

import models._
import views._

object Application extends Controller {

  val loginForm = Form(
    tuple(
      "name" -> text,
      "password" -> text) verifying ("Invalid username or password", result => result match {
        case (name, password) => password.equals("vioolkast") && User.authenticate(name).isDefined 
      }))

  def login = Action { implicit request =>
    Ok(views.html.login(loginForm))
  }

  def authenticate = Action { implicit request =>
    loginForm.bindFromRequest.fold(
      formWithErrors => BadRequest(views.html.login(formWithErrors)),
      user => Redirect(routes.Dashboard.index).withSession("name" -> "Nanne"))
  }

  def geo(lat: String, long: String) = Action { //Cached(req => "geo")
    def parseDouble(s: String) = try { Some(s.toDouble) } catch { case _ => 0 }
    DB.withConnection("osm") { implicit c =>
      def point: String = "POINT(" + long.toDouble.toString() + " " + lat.toDouble.toString + ")"

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
    	""").on("point" -> point, "radius" -> radius)().map({ t => Json.parse(t[String]("geometry")) }) toList))
    }
  }

}
/**
 * Provide security features
 */
trait Secured {
  /**
   * Retrieve the connected user email.
   */
  private def username(request: RequestHeader) = request.session.get("name")
  /**
   * Redirect to login if the user in not authorized.
   */
  private def onUnauthorized(request: RequestHeader) = Results.Redirect(routes.Application.login)
  /**
   * Action for authenticated users.
   */
  def IsAuthenticated(f: => String => Request[AnyContent] => Result) = Security.Authenticated(username, onUnauthorized) { user =>
    Action(request => f(user)(request))
  }
}
