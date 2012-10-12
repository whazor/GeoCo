@views ||= {}
class @views.Hints extends Backbone.View
    el: '#hints'
    initialize: ->
        for num in [9..14]
            t = new HintRow()
            @$el.find('table tbody').append t.render().el

class HintRow extends Backbone.View
    tagName: 'tr'
    initialize: -> #model.bind on change do render
    render: ->
        @$el.append '<th>13:00</th>'
        for num in [1..6]
            h = new Hint()
            @$el.append h.render().el
        @

class Hint extends Backbone.View
    tagName: 'td'
    initialize: -> #model.bind on change do render
    render: ->
        @$el.html '<button class="btn">Invullen</button>'
        @