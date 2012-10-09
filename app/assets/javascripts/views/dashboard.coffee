@views ||= {}
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": "reset"
    reset: -> false
    initialize: -> @map = new views.Maps