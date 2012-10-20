package controllers

import play.api._
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._

import libs.json.{JsObject, Json}
import play.api.libs.json.Json._
import models.{LatLng, Hunt, Hint, Coordinate}

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
  val hintForm = Form(
    tuple(
      "fox_group" -> text,
      "hour" -> number,
      "raw" -> text
    )
  )
  def create(sort: String) = IsAuthenticated { (user, request) =>
    val body = request.body.asJson.get
    sort match {
      case "hints" =>
        hintForm.bind(body).fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          value => Ok(
            Coordinate.createHint(
              value._1,
              user,
              value._3,
              value._2
            ).get.toJson
          )
        )
      case _ => BadRequest("Sort unknown")
    }
  }

  def update(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    val body = request.body.asJson.get
    sort match {
      case "hints" =>
        hintForm.bind(body).fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          value => Ok(
            Coordinate.updateHint(
              id,
              value._1,
              user,
              value._3,
              value._2
            ).get.toJson
          )
        )
      case _ => BadRequest("Sort unknown")
    }
  }

  def delete(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    sort match {
      case "hints" => if(Coordinate.delete(id)) { Ok("done.") } else { BadRequest("Failed") }
      case _ => BadRequest("Sort unknown")
    }
  }
}
