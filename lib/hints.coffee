# Hints handler
#
# Kijk naar het tabel, naar welke rijen wel en niet weergegeven moeten worden.
#

module.exports = class
  constructor: (@table) ->
    @data = []
    $.get '/hints.json', (data) =>
      @data = data
      @.redraw()

  redraw: ->
    for tr in $('tbody tr', @table)
      time = $(tr).data 'time'
      #console.log time
      for hint in @data
        console.log hint.time, time
      hints = _.select @data, (hint) -> time == hint.time
      console.log hints
