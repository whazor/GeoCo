package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json.Json
import play.api.libs.json.Json._

object Coordinates extends Controller with Secured {

  def list = IsAuthenticated { (user, request) =>
    Ok(toJson(
      List(
        Map(
          "fox_group" -> "alpha",
          "user" -> "Nanne",
          "point" -> "1, 4",
          "hour" -> "13"
        ),
        Map(
          "fox_group" -> "alpha",
          "user" -> "Nanne",
          "point" -> "1, 4",
          "hour" -> "14"
        )
      )
    ))
  }
  def read(id: Long) = IsAuthenticated { (user, request) =>
    Ok("Your new application is ready.")
  }
  def update(id: Long) = IsAuthenticated { (user, request) =>
    Ok("Your new application is ready.")
  }
  def create = IsAuthenticated { (user, request) =>
    Ok("Your new application is ready.")
  }
  def delete(id: Long) = IsAuthenticated { (user, request) =>
    Ok("Your new application is ready.")
  }
}
