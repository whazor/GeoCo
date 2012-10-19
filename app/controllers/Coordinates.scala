package controllers

import play.api._
import play.api.mvc._
import libs.json.{JsObject, Json}
import play.api.libs.json.Json._
import models.{Hunt, Hint, Coordinate}

object Coordinates extends Controller with Secured {

  def list(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    sort match {
      case "hints" =>
        Ok(toJson(Coordinate.allFromId(id).filter(c => c match {
          case x:Hint => true
          case _ => false
        }).map(h => h.toJson)))
      case "hunts" =>
        Ok(toJson(Coordinate.allFromId(id).filter(c => c match {
          case x:Hunt => true
          case _ => false
        }).map(h => h.toJson)))
      case _ => Ok(toJson(Coordinate.allFromId(id).map(h => h.toJson)))
    }
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
