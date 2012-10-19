$ =>
  col = new models.CoordinateCollection
  col.fetch error: (error) -> setTimeout col.fetch, 5000
  dashboard = new views.Dashboard collection: col
  class @Clock
    @start: (@interval) ->
      ""
window.MapTime = (i) ->
  ToDate: ->
    if i < 15 then new Date(2012, 10, 20, i + 9, 0, 0)
    else new Date(2012, 10, 21, i - 15, 0, 0)
  ToString: ->
    date = MapTime(i).ToDate()
    "#{date.getHours()}:00"
