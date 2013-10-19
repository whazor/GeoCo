package controllers

import play.api.db._
import anorm._
import play.api.Play.current
import play.api.mvc._
import play.api.cache.Cache


import play.api.libs.json._

import models.{LatLng, Coordinate}
import java.util.Date

object Coordinates extends Controller with Secured {
  /* caching */
  def list(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    def cs:Seq[Coordinate] = sort match {
      case "hints" => Cache.getOrElse[Seq[Coordinate]]("coordinates_hints") { getList("hints") }.filter(c => c.id.get > id)
      case "hunts" => Cache.getOrElse[Seq[Coordinate]]("coordinates_hunts") { getList("hunts") }.filter(c => c.id.get > id)
      case _ => Cache.getOrElse[Seq[Coordinate]]("coordinates_all") { getList("all") }.filter(c => c.id.get > id)
    }
    Ok(Json.toJson(cs.map(h => h.toJson)))
  }

  def emptyCache = IsAuthenticated { (user, request) =>
    resetList()
    Ok("HOI")
  }

  private def resetList() = {
    Cache.set("coordinates_hints", getList("hints"))
    Cache.set("coordinates_hunts", getList("hunts"))
    Cache.set("coordinates_all", getList("all"))
  }
  private def getList(sort: String): Seq[Coordinate] = {
    sort match {
        case "hints" =>
          Coordinate.all.filter { _.isInstanceOf[models.Hint] }
        case "hunts" =>
          Coordinate.all.filter { _.isInstanceOf[models.Hunt] }
        case _ => Coordinate.all
    }
  }

  case class Hint(fox_group: String, hour: Int, raw: String)
  case class Hunt(fox_group: String, found_at: Date, raw: String)

  def check(sort: String) = IsAuthenticated { (user, request) =>
    sort match {
      case "hints" => Json.reads[Hint].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res => Ok("ok")
        })

      case "hunts" => Json.reads[Hunt].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res => Ok("ok") })

      case _ => BadRequest("Sort unknown")
    }
  }

  /**
   * Creates a coordinate.
   * @param sort a hint or a hunt.
   * @return
   */
  def create(sort: String) = IsAuthenticated { (user, request) =>
    sort match {
      case "hints" => Json.reads[Hint].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res =>
          val c = Coordinate.createHint(res.fox_group, user, res.raw, res.hour).get.toJson
          resetList()
          Ok(c)
        })
      case "hunts" => Json.reads[Hunt].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res =>
          val c = Coordinate.createHunt(res.fox_group, user, res.raw, res.found_at).get.toJson
          resetList()
          Ok(c)
        })
      case _ => BadRequest("Sort unknown")
    }
  }

  def update(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    sort match {
      case "hints" => Json.reads[Hint].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res =>
          val c = Coordinate.updateHint(id, res.fox_group, user, res.raw, res.hour).get.toJson
          resetList()
          Ok(c)
        })
      case "hunts" => Json.reads[Hunt].reads(request.body.asJson.get).fold(
        invalid = { errors => BadRequest(JsError.toFlatJson(errors)) },
        valid = { res =>
          val c = Coordinate.updateHunt(id, res.fox_group, user, res.raw, res.found_at).get.toJson
          resetList()
          Ok(c)
        })
      case _ => BadRequest("Sort unknown")
    }
  }

  def delete(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    sort match {
      case "hunts" => if(Coordinate.delete(id)) {
        resetList()
        Ok("done.")
      } else { BadRequest("Failed") }

      case "hints" => if(Coordinate.delete(id)) {
        resetList()
        Ok("done.")
      } else { BadRequest("Failed") }
      case _ => BadRequest("Sort unknown")
    }
  }

  def geo(x:Int, y:Int) = IsAuthenticated { (user, request) =>
    DB.withConnection { implicit connection =>
      val point:String =
        SQL(
          """
              select ST_AsText(ST_Transform(ST_SetSRID(ST_Point({x}, {y}), 28992), 4326)) as coordinate;
          """.stripMargin).on('x -> x, 'y -> y)().head[String]("coordinate")

      val p1:String = point.stripPrefix("POINT(")
      val p2:String = p1.stripSuffix(")")
      def c = p2.split(" ")
      def latlng = LatLng(c(0).toDouble, c(1).toDouble)

      Ok(Json.obj(
        "lat" -> latlng.lat,
        "lng" -> latlng.long
      ))
    }
  }
}
