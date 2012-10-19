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
    if i < 15 then new Date(2012, 10, 20, i + 9, 0, 0)
    else new Date(2012, 10, 21, i - 15, 0, 0)
  ToString: ->
    date = MapHour(i).ToDate()
    "#{date.getHours()}:00"

class @Clock
  @listeners = []

  @start: (@interval) ->
    @id = setInterval @tick, @interval

  @tick = =>
    for listener in @listeners
      listener()
  @stop: ->
    clearInterval @id