@views ||= {}
current = false
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

    @$el.on 'click', '.btn-fillin', (e) ->
      return if $(@) == current
      form = new Form($(@)).render().el
      $(@).popover
        title: 'Hint invoeren'
        placement: $(@).attr 'data-align'
        content: form
      if current
        current.popover 'hide'
        current = false
      current = $(@)
      $(@).popover 'show'
      $(@).data('popover').$tip.find('form input')[0].focus()
      $(window).unbind 'resize.popover'
      $(window).bind 'resize.popover', -> current.popover 'show'
      $(form).bind 'close', (e) ->
        current.popover 'hide'
        current = false
    @

class Hint extends Backbone.View
  tagName: 'td'
  initialize: (i) -> @i = i #model.bind on change do render
  bind: (model) => model.bind 'change', @render
  render: =>
    btn = $ '<button class="btn btn-fillin">Invullen</button>'
    btn.attr 'data-align', if @i <= 3 then 'right' else 'left'
    @$el.append btn
    @

class Form extends Backbone.View
#  initialize: (btn) -> @btn = btn
  tagName: 'form'
  render: =>
    @$el.append $ """
      <div>
        <label>Coördinaat:</label>
        <input type="text" class="input-mini" style="width: 40%; float: left;">
        <input type="text" class="input-mini" style="width: 40%; float: right;">
        <button type="submit" class="btn btn-primary btn-small">Aanmaken</button>
        <button onclick="$(this).parent().parent().trigger('close'); return false;" class="btn btn-small btn-close">Sluiten</button>
      </div>
      """
    @