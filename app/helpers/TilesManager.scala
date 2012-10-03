package helpers

import play.api.Play.current
import play.api.db.DB
import anorm._
import play.api.libs.iteratee.Enumerator

object TilesManager {
	def empty = new java.io.FileInputStream(current.getFile("tiles/missing.png")) 

	def get(zoom: Int, column: Int, inputRow: Int, tries: Int = 0): Enumerator[Array[Byte]] = {
	  try {
		DB.withConnection("tiles") { implicit c =>
			def row(): Int = (math.pow(2, zoom) - 1 - inputRow).toInt
			def q = SQL("select tile_data from tiles where zoom_level = {zoom} and tile_column = {column} and tile_row = {row} limit 1").on("zoom" -> zoom, "column" -> column, "row" -> row())
	
			val resultSet = q.resultSet
			Enumerator(Iterator.continually((resultSet, resultSet.next)).takeWhile(_._2).map(_._1).map { res =>
			res.getBytes(1)
			}.toIterable.head)
		}
	  } catch {
	    case e: NoSuchElementException => Enumerator.fromStream(empty)
	  }
	}
}