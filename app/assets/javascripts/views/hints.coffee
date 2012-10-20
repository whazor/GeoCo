@views ||= {}
current = false
class @views.Hints extends Backbone.View
  el: '#hints table tbody'
  initialize: (@collection, @maps, options) ->
    @hints = []
    @collection.bind 'add', @set, @
    @collection.bind 'reset', (-> _.each @collection.models, @set), @
    @$el.empty()
    for hour in [0..30]
      @hints[hour] ||= []
      tr = $ "<tr id=hour-#{hour}><th>#{window.MapHour(hour).ToString()}</th></tr>"
      for name, index in window.fox_groups
        hint = @hints[hour][name] = new Hint index, name, hour, @collection
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
    @$el.attr("id", "#{@hour} - #{@name}")
    @$el.data("content", @form = $ """
      <div>
        <label>Coördinaat:</label>
        <input type="text" class="input-mini input-raw" style="width: 90%">
        <div class="btn-group">
          <button type="submit" class="btn btn-primary btn-small create-btn">Aanmaken</button>
          <button class="btn btn-danger btn-small delete-btn">Verwijderen</button>
          <button class="btn btn-small btn-close" data-dismiss="clickover">Sluiten</button>
        </div>
      </div>
      """);
    @$el.clickover
      title: 'Hint invoeren'
      placement: if index < 3 then 'right' else 'left'
      trigger:  "manual"
      onShown: (e) =>
        $("button.create-btn", @form).on "click.clickover", =>
          data =
            fox_group: @name
            hour: @hour
            raw: $(".input-raw", @form).val()
          save = =>
            if(@model)
              console.log "test"
              @model.set data
              @model.save()
            else
              @collection.create data
          if /\d+(\.\d+)?[, ;]+\d+(\.\d+)?/.test data.raw
            save()
          else
            window.geocoder.geocode address: data.raw, (results, status) ->
              return unless status == google.maps.GeocoderStatus.OK
              data.raw = "#{results[0].geometry.location.lat()} #{results[0].geometry.location.lng()}"
              save()
        $("button.delete-btn", @form).on "click.clickover", =>
          model = @model
          @model = null
          model.destroy()

      onHidden: ->
        $("button.create-btn", @form).off "click.clickover"
        $("button.delete-btn", @form).off "click.clickover"
    @$el.append $('<button class="btn btn-fillin">Invullen</button>')
    @render()

  bind: (@model, @collection) =>
    @model.bind 'change', @render
    @model.bind 'destroy', @render
    @render()
  render: =>
    if @model?
      @$el.css "background-color", "#e6fbe6"
      $(".input-raw", @form).val @model.get "raw"
      $(".create-btn", @form).text "Aanpassen"
      $(".delete-btn", @form).removeAttr 'disabled'
    else
      $(".input-raw", @form).val ""
      $(".delete-btn", @form).attr 'disabled', 'disabled'
      @$el.css "background-color", "white"
