$ =>
  window.hints = new window.HintCollection
  window.hunts = new window.HuntCollection

  dashboard = new views.Dashboard

  @utilities.AutoUpdate window.hints
  @utilities.AutoUpdate window.hunts
  @Clock.start 1000

window.fox_groups = ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]
window.fox_colors =
  alpha: "#FF0000"
  bravo: "#00FF00"
  charlie: "#0000FF"
  delta: "#00FFFF"
  echo: "#FF00FF"
  foxtrot: "#FFFF00"
window.MapHour = (i) ->
  ToDate: ->
    base = new Date(2012, 9, 20, 9, 0, 0)
    base.setHours base.getHours() + i
    base
  ToString: ->
    date = MapHour(i).ToDate()
    "#{date.getHours()}:00"
window.MapTime = (time) ->
  ToHour: ->
    base = new Date(2012, 9, 20, 9, 0, 0)
    ((time - base.getTime()) / 1000 / 60 / 60) % 30

class @Clock
  @listeners = []

  @start: (@interval) ->
    @id = setInterval @tick, @interval

  @tick = =>
    for listener in @listeners
      listener()
  @stop: ->
    clearInterval @id