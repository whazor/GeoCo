package controllers

import play.api._
import play.api.mvc._

object Dashboard extends Controller with Secured {
  def index = IsAuthenticated { (user, request) =>
      Ok(views.html.index("Your new application is ready."))
  }

}