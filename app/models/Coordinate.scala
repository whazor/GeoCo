package models

import play.api.db._
import play.api.Play.current
import anorm._
import anorm.SqlParser._
import java.util.Date
import play.api.libs.json._
import ch.qos.logback.classic.pattern.DateConverter

abstract class Coordinate() {
  def id: Pk[Long]
  def fox_group: String
  def created_at: Date
  def user_id: Pk[Int]
  def user(): Option[User] = User.getById(user_id.get)
  def raw: String
  def point: LatLng
  def point_rgd: (Int, Int)
  def time: Date
  def toJson: JsValue
  def map: Map[String, JsValue] = Map(
    "id" -> Json.toJson(id.get),
    "fox_group" -> Json.toJson(fox_group),
    "created_at" -> Json.toJson(created_at.getTime()),
    "time" -> Json.toJson(time.getTime()),
    "user_id" -> Json.toJson(user_id.get),
    "lat" -> Json.toJson(point.lat),
    "lng" -> Json.toJson(point.long),
    "x" -> Json.toJson(point_rgd._1),
    "y" -> Json.toJson(point_rgd._2),
    "raw" -> Json.toJson(raw)
  )
}
case class Hint(
    id: Pk[Long],
    fox_group: String,
    created_at: Date,
    user_id: Pk[Int],
    raw: String,
    point: LatLng,
    point_rgd: (Int, Int),
    time: Date,
    hour: Int
    ) extends Coordinate {
  def toJson: JsValue = Json.toJson(map ++ Map("hour" -> Json.toJson(hour)))
}
case class Hunt(
    id: Pk[Long],
    fox_group: String,
    created_at: Date,
    user_id: Pk[Int],
    raw: String,
    point: LatLng,
    point_rgd: (Int, Int),
    time: Date,
    found_at: Date
    ) extends Coordinate {
  def toJson: JsValue = Json.toJson(map ++ Map("found_at" -> Json.toJson(found_at.toString())))
}

object Coordinate {
  val simple = {
    get[String]("type") ~
    get[Pk[Long]]("coordinate_id") ~
    get[String]("fox_group") ~
    get[Date]("created_at") ~
    get[Pk[Int]]("user_id") ~
    get[String]("raw") ~
    get[String]("point_4326") ~
    get[String]("point_28992") ~
    //get[Pk[Long]]("nearest_way_id") ~
    get[Date]("hint_time") ~
    (get[Date]("found_at") | get[Int]("hint_hour"))
  } map {
    case "hint"~id~fox_group~created_at~user_id~raw~point1~point2~time~(hour:Int) => {
      val p1:String = point1.stripPrefix("POINT(").stripSuffix(")")
      val p2:String = point2.stripPrefix("POINT(").stripSuffix(")")
      val c1 = p1.split(" ")
      val c2 = p2.split(" ")
      Hint(id, fox_group, created_at, user_id, raw, LatLng(c1(0).toDouble, c1(1).toDouble), (c2(0).toDouble.toInt, c2(1).toDouble.toInt), time, hour)
    }
    case "hunt"~id~fox_group~created_at~user_id~raw~point1~point2~time~(found_at:Date) => {
      val p1:String = point1.stripPrefix("POINT(").stripSuffix(")")
      val p2:String = point2.stripPrefix("POINT(").stripSuffix(")")
      val c1 = p1.split(" ")
      val c2 = p2.split(" ")
      Hunt(id, fox_group, created_at, user_id, raw, LatLng(c1(0).toDouble, c1(1).toDouble), (c2(0).toDouble.toInt, c2(1).toDouble.toInt), time, found_at)
    }
  }
  val sqlCoordinate =
    """
      |coordinate_id,
      |fox_group,
      |created_at,
      |raw,
      |ST_AsText(point) as point_4326,
      |ST_AsText(ST_Transform(point, 28992)) as point_28992,
      |user_id
    """.stripMargin

  val sqlHint =
    """
      |, hint_hour
      |, timestamp '2012-10-20 08:55:00' + (20 || ' hours')::interval as hint_time
    """.stripMargin
  val sqlHunt =
    """
      |, found_at
      |, found_at as hint_time
    """.stripMargin
  def allFromId(id: Long): Seq[Coordinate] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
            select 'hint' as type,
        """ + sqlCoordinate + sqlHint +
          """
          from hints
          where coordinate_id > {id}
          """).on("id" -> id).as(Coordinate.simple *) ++
      SQL(
        """
         select 'hunt' as type,
        """ + sqlCoordinate + sqlHunt +
          """, found_at
          from hunts
          where coordinate_id > {id}
          """).on("id" -> id).as(Coordinate.simple *)
    }
  }

  def getById(id: Long, sort: String): Option[Coordinate] = {
    DB.withConnection { implicit connection =>
      sort match {
        case "hints" => SQL("""
          select 'hint' as type,""" + sqlCoordinate + sqlHint + """
          from hints where coordinate_id = {id} limit 1""").on("id" -> id).as(Coordinate.simple.singleOpt)
        case "hunts" => SQL("""
          select 'hunt' as type,""" + sqlCoordinate + sqlHunt + """
          from hints where coordinate_id = {id} limit 1""").on("id" -> id).as(Coordinate.simple.singleOpt)
      }
    }
  }

  private def rawToGeo(raw: String): (Double, Double, Int) = {
    val r = raw.split(Array(',', ' ', ';'))

    val r1 = r(0)
    val r2 = r(1)

    val srid = if (r1.toDouble < 100 && r2.toDouble < 100) {
      4326
    } else {
      28992
    }
    val x = if (srid == 4326) {
      r2.toDouble
    } else {
      math.pow(10, math.max(0, 6 - ("" + r1).length)) * r1.toDouble
    }
    val y = if (srid == 4326) {
      r1.toDouble
    } else {
      math.pow(10, math.max(0, 6 - ("" + r2).length)) * r2.toDouble
    }
    (x, y, srid)
  }

  def createHint(fox_group: String, user: User, raw: String, hour: Int): Option[Coordinate] = {
    DB.withConnection { implicit connection =>
      val (x, y, srid) = rawToGeo(raw)
      val insertId = SQL(
        """
        INSERT INTO hints(fox_group, created_at, user_id, raw, point, hint_hour)
        VALUES ({fox_group}, NOW(), {user_id}, {raw}, ST_Transform(ST_SetSRID(ST_Point({x}, {y}), {srid}), 4326), {hour})
        """).on(
          'fox_group -> fox_group,
          'user_id -> user.id,
          'raw -> raw,
          'x -> x,
          'y -> y,
          'hour -> hour,
          'srid -> srid
        ).executeInsert()
      insertId match {
        case Some(id) => getById(id, "hints")
        case None => None
      }
    }
  }
  def updateHint(id: Long, fox_group: String, user: User, raw: String, hour: Int): Option[Coordinate] = {
    DB.withConnection { implicit connection =>
      val (x, y, srid) = rawToGeo(raw)
      val updateId = SQL(
        """
        UPDATE hints
        SET
          fox_group = {fox_group},
          user_id = {user_id},
          raw = {raw},
          point = ST_Transform(ST_SetSRID(ST_Point({x}, {y}), {srid}), 4326),
          hint_hour = {hour}
        WHERE coordinate_id = {id};
        """).on(
        'fox_group -> fox_group,
        'user_id -> user.id,
        'raw -> raw,
        'x -> x,
        'y -> y,
        'hour -> hour,
        'srid -> srid,
        'id -> id
      ).executeUpdate()
      getById(id, "hints")
    }
  }
  def delete(id: Long): Boolean = {
    DB.withConnection { implicit connection =>
      SQL(
        """
          |DELETE FROM coordinates
          |WHERE coordinate_id = {id};
        """.stripMargin).on('id -> id).executeUpdate() > 0
    }
  }
}