package controllers

import play.api._
import play.api.db._
import anorm._
import anorm.SqlParser._
import play.api.Play.current
import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.cache.Cache

import libs.json.{JsObject, Json}
import play.api.libs.json.Json._
import models.{LatLng, Hunt, Hint, Coordinate}

object Coordinates extends Controller with Secured {

  def list(sort: String, id: Long) = IsAuthenticated { (user, request) =>
//    Cache.getOrElseAs[Seq[Coordinate]]("coordinates_hints") {}
    def cs:Seq[Coordinate] = sort match {
      case "hints" => Cache.getOrElse[Seq[Coordinate]]("coordinates_hints") { getList("hints") }.filter(c => c.id.get > id)
      case "hunts" => Cache.getOrElse[Seq[Coordinate]]("coordinates_hunts") { getList("hunts") }.filter(c => c.id.get > id)
      case _ => Cache.getOrElse[Seq[Coordinate]]("coordinates_all") { getList("all") }.filter(c => c.id.get > id)
    }
    Ok(toJson(cs.map(h => h.toJson)))
  }
  private def resetList() = {
    Cache.set("coordinates_hints", getList("hints"))
    Cache.set("coordinates_hunts", getList("hunts"))
    Cache.set("coordinates_all", getList("all"))
  }
  private def getList(sort: String): Seq[Coordinate] = {
    sort match {
        case "hints" =>
          Coordinate.all.filter(c => c match {
            case x:Hint => true
            case _ => false })
        case "hunts" =>
          Coordinate.all.filter(c => c match {
            case x:Hunt => true
            case _ => false })
        case _ => Coordinate.all
    }
  }


  val hintForm = Form(
    tuple(
      "fox_group" -> text,
      "hour" -> number,
      "raw" -> text
    )
  )
  val huntForm = Form(
    tuple(
      "fox_group" -> text,
      "found_at" -> play.api.data.Forms.date,
      "raw" -> text
    )
  )
  def create(sort: String) = IsAuthenticated { (user, request) =>
    val body = request.body.asJson.get
    sort match {
      case "hints" =>
        hintForm.bind(body).fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          value => {
            val c = Coordinate.createHint(
                value._1,
                user,
                value._3,
                value._2
              ).get.toJson
            resetList()
            Ok(c)
          }
        )
      case "hunts" =>
        huntForm.bind(body).fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          value => {
            val c = Coordinate.createHunt(
              value._1,
              user,
              value._3,
              value._2
            ).get.toJson
            resetList()
            Ok(c)
          }
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
          value => {
            val c = Coordinate.updateHint(
              id,
              value._1,
              user,
              value._3,
              value._2
            ).get.toJson
            resetList()
            Ok(c)
          }
        )
      case "hunts" =>
        huntForm.bind(body).fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          value => {
            val c = Coordinate.updateHunt(
              id,
              value._1,
              user,
              value._3,
              value._2
            ).get.toJson
            resetList()
            Ok(c)
          }
        )
      case _ => BadRequest("Sort unknown")
    }
  }

  def delete(sort: String, id: Long) = IsAuthenticated { (user, request) =>
    sort match {
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

      Ok(toJson(
        Map(
          "lat" -> latlng.lat,
          "lng" -> latlng.long
        )
      ))
    }
  }
}
