package controllers

import play.api._
import play.api.mvc._
import helpers._

object Tiles extends Controller {
  def get(zoom: String, column: String, row: String) = Action {
    def round(x: String): Int = x.toDouble.floor.toInt
    try {
	    def content = TilesManager.get(round(zoom), round(column), round(row))
	    SimpleResult(
	      header = ResponseHeader(200),
	      body = content
	    )
    } catch {
	  case e: NoSuchElementException => NotFound("Tile not found")
	}
  }
}