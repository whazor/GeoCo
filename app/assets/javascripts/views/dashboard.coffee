@views ||= {}
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": "reset"
    reset: -> false
    initialize: (coordinates) ->
        @maps = new views.Maps window.hints, window.hunts
        @hints = new views.Hints window.hints