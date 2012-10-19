$ =>
  window.hints = new window.HintCollection
  window.hunts = new window.HuntCollection

  @utilities.AutoUpdate window.hints
  @utilities.AutoUpdate window.hunts

  dashboard = new views.Dashboard
  @Clock.start 1000



window.fox_groups = ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]
window.fox_colors =
  alpha: "#9d261d"
  bravo: "#46a546"
  charlie: "#0064cd"
  delta: "#049cdb"
  echo: "#d5a100"
  foxtrot: "#c3325f"
window.MapHour = (i) ->
  ToDate: ->
    base = new Date(2012, 10, 20, 9, 0, 0)
    base.setHours base.getHours() + i
    base
  ToString: ->
    date = MapHour(i).ToDate()
    "#{date.getHours()}:00"
window.MapTime = (time) ->
  ToHour: ->
    base = new Date(2012, 10, 20, 9, 0, 0)
    (time - base) / 1000 / 60 / 60

class @Clock
  @listeners = []

  @start: (@interval) ->
    @id = setInterval @tick, @interval

  @tick = =>
    for listener in @listeners
      listener()
  @stop: ->
    clearInterval @id