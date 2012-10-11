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
      user => Redirect(routes.Dashboard.index).withSession("user_id" -> "1"))
  }
}
/**
 * Security methods
 */
trait Secured {
  /**
   * Send the user to the login screen.
   */
  private def onUnauthorized(request: RequestHeader) = Results.Redirect(routes.Application.login)
  /**
   * Look if the user is logged in or send a redirect.
   */
  def IsAuthenticated(f: (User, Request[AnyContent]) => Result) = {
    Action { request =>
      request.session.get("user_id").flatMap(u => User.getById(u.toInt)).map { user =>
        f(user, request)
      }.getOrElse { onUnauthorized(request) }
    }
  }
}
