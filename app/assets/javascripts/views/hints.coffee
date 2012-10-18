@views ||= {}
class @views.Hints extends Backbone.View
  el: '#hints table tbody'
  initialize: (options) ->
    @hints = []
    @render()
    @collection.bind 'add', @add, @
    @collection.bind 'reset', (-> _.each @collection.models, @add), @

  add: (h) =>
    @hints[parseInt h.get 'hour'][h.get 'fox_group'].bind h
  render: =>
    @$el.empty()
    for i in [9..15]
      @hints[i] ||= []
      tr = $ '<tr>'
      tr.append "<th>#{i}:00</th>"
      for j, k in ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]
        @hints[i][j] = new Hint k
        tr.append @hints[i][j].render().el
      @$el.append tr
    @

current = false
class Hint extends Backbone.View
  tagName: 'td'
  initialize: (i) -> @i = i #model.bind on change do render
  bind: (model) => model.bind 'change', @render
  render: =>
    current.popover 'hide' if current
    btn = $ '<button class="btn">Invullen</button>'
    btn.attr 'data-original-title', 'Hint invullen'

    btn.popover placement: if @i <= 3 then 'right' else 'left'
    btn.bind 'click', (e) ->
      return if btn == current
      current.popover 'hide' if current
      current = btn
      btn.popover 'show'
      btn.attr 'data-content', $(new Form().render().el).html()
      $(window).unbind 'resize.popover'
      $(window).bind 'resize.popover', -> current.popover 'show'
      $('.btn.btn-close').unbind('click').bind 'click', ->
        current.popover 'hide'
        false
    @$el.append btn
    @

class Form extends Backbone.view
  tagName: 'form'
  render: =>
    @$el.html """
      <label>Coördinaat:</label>
      <input type="text" class="input-mini" style="width: 40%; float: left;">
      <input type="text" class="input-mini" style="width: 40%; float: right;">
      <button type="submit" class="btn btn-primary btn-small">Aanmaken</button>
      <button class="btn btn-small btn-close">Sluiten</button>
    """
    @
