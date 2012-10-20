@views ||= {}
current = false
class @views.Hints extends Backbone.View
  el: '#hints table tbody'
  initialize: (@collection, @maps, options) ->
    @hints = []
    @collection.bind 'add', @set, @
    @collection.bind 'reset', (-> _.each @collection.models, @set), @
    @$el.empty()
    for hour in [15..30]
      @hints[hour] ||= []
      tr = $ "<tr id=hour-#{hour}><th>#{window.MapHour(hour).ToString()}</th></tr>"
      for name, index in window.fox_groups
        hint = @hints[hour][name] = new Hint index, name, hour, @collection, @maps
        tr.append hint.el
        hint.render()
      @$el.append tr
    @

  set: (h) =>
    return unless @hints[parseInt h.get 'hour']?
    @hints[parseInt h.get 'hour'][h.get 'fox_group'].bind h, @collection

class Hint extends Backbone.View
  tagName: 'td'
  className: "Hint"
  initialize: (index, @name, @hour, @collection, @maps) ->
    @$el.attr("id", "#{@hour} - #{@name}")
    @$el.data("content", @form = $ """
                  <div>
                    <label>Coördinaat:</label>
                    <pre class="data"></pre>
                    <input type="text" class="input-mini input-raw" style="width: 90%">
                    <div class="btn-group">
                      <button type="submit" class="btn btn-primary btn-small create-btn">Aanmaken</button>
                      <button class="btn btn-danger btn-small delete-btn">Verwijderen</button>
                      <button class="btn btn-small btn-close" data-dismiss="clickover">Sluiten</button>
                      <button class="btn btn-small zoom-btn">Zoom</button>
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
        $("button.zoom-btn", @form).on "click.clickover", =>
          @maps.zoom new google.maps.LatLng(@model.get("lat"), @model.get("lng")), 13

        $("a.address-a").on "click.clickover", =>
          window.geocoder.geocode latLng: new google.maps.LatLng @model.get("lat"),  @model.get("lng"), ([result], success) ->
            $("a.address-a").replaceWith $ """<span title="#{result.formatted_address}">#{result.formatted_address}</span>"""

      onHidden: ->
        $("button.create-btn", @form).off "click.clickover"
        $("button.delete-btn", @form).off "click.clickover"
        $("button.zoom-btn", @form).off "click.clickover"
        $("a.address-a", @form).off "click.clickover"
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
      text = ""
      text += "Coördinaat:\n" if @model.has("lat") and @model.has "lng"
      text += "  Lat:  #{@model.get "lat"}\n" if @model.has "lat"
      text += "  Lng:  #{@model.get "lng"}\n" if @model.has "lng"
      text += "Rijksdriehoek:\n" if @model.has("x") and @model.has "y"
      text += "  x:    #{@model.get "x"}\n" if @model.has "x"
      text += "  y:    #{@model.get "y"}\n" if @model.has "y"
      $(".data", @form).text text
      if @model.has("lat") and @model.has "lng"
        $(".data", @form).append "Adres:\n  "
        adres = $ """<a class="address-a">Laden</a>"""
        $(".data", @form).append adres

      $(".data", @form).show()
    else
      $(".input-raw", @form).val ""
      $(".delete-btn", @form).attr 'disabled', 'disabled'
      @$el.css "background-color", "white"
      $(".data", @form).text ""
      $(".data", @form).hide()

class window.ModelPopup extends Backbone.View
  initialize: ->
    @fields = @options.fields
    @label = @options.label ? @model.constructor.name
    @$el.append $ """<label>#{@label}:</label>"""
    for {name, type} in @fields
      field = $ switch type.toLowerCase()
        when "label"
          "<label>#{name}</label>"
        when "text"
          """<input type="text" class="input-mini input-#{name.toLowerCase()}" style="width: 90%">"""
      @$el.append field
      field.val @model.get name if @model.has name
    @$el.append $ """
      <div class="btn-group">
        <button type="submit" class="btn btn-primary btn-small create-btn">Aanmaken</button>
        <button class="btn btn-danger btn-small delete-btn">Verwijderen</button>
        <button class="btn btn-small btn-close" data-dismiss="clickover">Sluiten</button>
      </div>
    """
    $("button.create-btn", @form).off "click.clickover"
    $("button.delete-btn", @form).off "click.clickover"

    @model.on "change", console.log
