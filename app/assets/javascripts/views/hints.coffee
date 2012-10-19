@views ||= {}
current = false
class @views.Hints extends Backbone.View
  el: '#hints table tbody'
  initialize: (@collection, options) ->
    @hints = []
    @collection.bind 'add', @set, @
    @collection.bind 'reset', (-> _.each @collection.models, @set), @
    @$el.empty()
    for time in [0..30]
      @hints[time] ||= []
      tr = $ "<tr><th>#{window.MapTime(time).ToString()}</th></tr>"
      for name, index in ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]
        hint = @hints[time][name] = new Hint index, name, time, @collection
        tr.append hint.el
        hint.render()
      @$el.append tr
    @

  set: (h) =>
    @hints[parseInt h.get 'hour'][h.get 'fox_group'].bind h, @collection

class Hint extends Backbone.View
  tagName: 'td'
  className: "Hint"
  initialize: (index, @name, @hour, @collection) ->
    @$el.data("content", form = $ """
          <div>
            <label>Coördinaat:</label>
            <input type="text" class="input-mini input-lat" style="width: 40%; float: left;">
            <input type="text" class="input-mini input-lng" style="width: 40%; float: right;">
            <button type="submit" class="btn btn-primary btn-small">Aanmaken</button>
            <button class="btn btn-small pull-right btn-close" data-dismiss="clickover">Sluiten</button>
          </div>
          """);
    @$el.clickover
      title: 'Hint invoeren'
      placement: if index < 3 then 'right' else 'left'
      trigger:  "manual"
      onShown: =>
        $("button[type=submit]", form).on "click.clickover", =>
          data =
            fox_group: @name
            hour: @hour
            lat: $("lat", form).val()
            lng: $("lng", form).val()
          if(@model)
            @model.set data
            @model.save
          else
            @collection.create data


      onHidden: ->
        $("button[type=submit]", form).off "click.clickover"
    @$el.append $('<button class="btn btn-fillin">Invullen</button>')

  bind: (@model, @collection) =>
    @model.bind 'change', @render
    @render
  render: -> @
