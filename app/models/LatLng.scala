package models

class LatLng(_long: Double, _lat: Double) {
  def long = _long
  def lat = _lat
  def array = Seq(long, lat)
  override def toString = "POINT(" + long + " " + lat + ")"
}

object LatLng {
  def apply(a: Double, b: Double): LatLng = new LatLng(a, b)
  def apply(a: String, b: String): LatLng = new LatLng(a.toDouble, b.toDouble)
  def apply(input: Seq[Double]):LatLng = new LatLng(input(0), input(1))
}