@views ||= {}
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": "reset"
    reset: -> false
    initialize: ->
        console.log 'test'
        @map = new views.Maps