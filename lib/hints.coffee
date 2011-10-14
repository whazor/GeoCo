# Hints handler
#
# Kijk naar het tabel, naar welke rijen wel en niet weergegeven moeten worden.
#

module.exports = class
  constructor: (@table) ->
    @data = []
    $.get '/hints/#{year}.json', (data) =>
      @data = data
      @.redraw()

  redraw: ->
    for tr in $ 'tbody tr', @table
      time = $(tr).data 'time'
      #console.log time
      hints = _.select @data, (hint) -> time == hint.time
      for hint in hints
        el = $('.'+hint.fox_group, tr)
        link = $('<a href="#" />').html hint.solver
        link.data 'longlat',
          lat: hint.longlat.x
          lon: hint.longlat.y
        link.bind 'click', (e) ->
          map.center $(@).data('longlat')

          map.zoom(15)
          return false
        el.html ''
        el.append link

