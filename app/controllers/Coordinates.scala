package controllers

import play.api._
import play.api.mvc._
import libs.json.{JsObject, Json}
import play.api.libs.json.Json._
import models.{Hunt, Hint, Coordinate}

object Coordinates extends Controller with Secured {

  def list = IsAuthenticated { (user, request) =>
    Ok(toJson(
      Map(
        "hints" -> Coordinate.all.filter(c => c match {
          case x:Hint => true
          case _ => false
        }).map(h => h.toJson),
        "hunts" -> Coordinate.all.filter(c => c match {
          case x:Hunt => true
          case _ => false
        }).map(h => h.toJson)
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
