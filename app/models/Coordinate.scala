package models

import play.api.db._
import play.api.Play.current
import anorm._
import anorm.SqlParser._
import java.util.Date
import play.api.libs.json._

abstract class Coordinate() {
  def id: Pk[Long]
  def fox_group: String
  def created_at: Date
  def user_id: Pk[Int]
//    def user: => User
  def user(): Option[User] = User.getById(user_id.get)
  def point: LatLng
 // def nearest_way_id: Pk[Long]
  def toJson: JsValue
  def map: Map[String, JsValue] = Map(
    "id" -> Json.toJson(id.get),
    "fox_group" -> Json.toJson(fox_group),
    "created_at" -> Json.toJson(created_at.toString()),
    "user_id" -> Json.toJson(user_id.get),
    "point" -> Json.toJson(point.array)
  )
}
case class Hint(
    id: Pk[Long],
    fox_group: String,
    created_at: Date,
    user_id: Pk[Int],
    point: LatLng,
    //nearest_way_id: Pk[Long],
    hour: Int
    ) extends Coordinate {
  def toJson: JsValue = Json.toJson(map ++ Map("hour" -> Json.toJson(hour)))
}
case class Hunt(
    id: Pk[Long],
    fox_group: String,
    created_at: Date,
    user_id: Pk[Int],
    point: LatLng,
//    nearest_way_id: Pk[Long],
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
    get[String]("point") ~
    //get[Pk[Long]]("nearest_way_id") ~
    (get[Date]("found_at") | get[Int]("hint_hour"))
  } map {
    case "hint"~id~fox_group~created_at~user_id~point~(hour:Int) => {
      val p1:String = point.stripPrefix("POINT(")
      val p2:String = p1.stripSuffix(")")
      def c = p2.split(" ")
      Hint(id, fox_group, created_at, user_id, LatLng(c(0).toDouble, c(1).toDouble), hour)
    }
    case "hunt"~id~fox_group~created_at~user_id~point~(found_at:Date) => {
      val p1:String = point.stripPrefix("POINT(")
      val p2:String = p1.stripSuffix(")")
      def c = p2.split(" ")
      Hunt(id, fox_group, created_at, user_id, LatLng(c(0).toDouble, c(1).toDouble), found_at)
    }
  }
  val sqlCoordinate =
    """
      coordinate_id,
      fox_group,
      created_at,
      ST_AsText(point) as point,
      user_id
    """.stripMargin // nearest_way_id bigint,

  def allFromId(id: Long): Seq[Coordinate] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
            select 'hint' as type,
        """ + sqlCoordinate +
          """, hint_hour
          from hints
          where coordinate_id > {id}
          """).on("id" -> id).as(Coordinate.simple *) ++
      SQL(
        """
         select 'hunt' as type,
        """ + sqlCoordinate +
          """, found_at
          from hunts
          where coordinate_id > {id}
          """).on("id" -> id).as(Coordinate.simple *)
    }
  }

  def getById(id: Long): Option[Coordinate] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
          select 'hint',""" + sqlCoordinate + """, publiced_at
          from hints where coordinate_id = {id}
          union all
          select 'hunt',""" + sqlCoordinate + """, found_at
          from hunts where coordinate_id = {id}
        """).on("id" -> id).as(Coordinate.simple.singleOpt)
    }
  }

  def createHint(fox_group: String, user: User, point: LatLng, publiced_at: Date): Option[Coordinate] = {
    DB.withConnection { implicit connection =>
      val insertId = SQL(
        """
        INSERT INTO hints(fox_group, created_at, user_id, point, publiced_at)
        VALUES ({fox_group}, NOW(), {user_id}, {point}, {publiced_at})
        """).on(
          'fox_group -> fox_group,
          'user_id -> user.id,
          'point -> point,
          'publiced_at -> publiced_at
        ).executeInsert()
      insertId match {
        case Some(id) => getById(id)
        case None => None
      }
    }
  }
}