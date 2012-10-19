@views ||= {}
current = false
class @views.Hints extends Backbone.View
  el: '#hints table tbody'
  initialize: (options) ->
    @hints = []
    @render()
    @collection.bind 'add', @set, @
    @collection.bind 'reset', (-> _.each @collection.models, @set), @



  set: (h) =>
    @hints[parseInt h.get 'hour'][h.get 'fox_group'].bind h

  render: =>
    @$el.empty()
    for time in [0..30]
      @hints[time] ||= []
      tr = $ "<tr><th>#{window.MapTime(time).ToString()}</th></tr>"
      for name, index in ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot"]
        hint = @hints[time][name] = new Hint index, name, time
        tr.append hint.el
        hint.render()
      @$el.append tr
    @

class Hint extends Backbone.View
  tagName: 'td'
  className: "Hint"
  initialize: (index, @name, @time) ->
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
      onShown: ->
        $("button[type=submit]", form).on "click.clickover", =>
          $.ajax "/coordinates",
            type: "POST"
            data:
              fox_group: @name
              time: @time
              lat: $("lat", form).val()
              lng: $("lng", form).val()
            dataType: "json"
            complete: (data, status) =>
              switch status
                when 200 then # Success

                when 409 then # Already exists


      onHidden: ->
        $("button[type=submit]", form).off "click.clickover"
    @$el.append $('<button class="btn btn-fillin">Invullen</button>')

  bind: (@model) => @model.bind 'change', @render
  render: -> @
