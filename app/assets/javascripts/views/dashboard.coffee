@views ||= {}
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": "reset"
    reset: -> false
    initialize: (coordinates) ->
        @map = new views.Maps
        @hints = new views.Hints(coordinates, @maps)