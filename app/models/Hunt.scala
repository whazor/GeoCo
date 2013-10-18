package models

import anorm.Pk
import java.util.Date
import play.api.libs.json._

/**
 * Made by: nanne 18-10-13
 */
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
