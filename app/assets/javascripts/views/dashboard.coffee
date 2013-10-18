@views ||= {}
zoom = 100
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": -> false
        "keydown #Search": (e) ->
          return unless e.keyCode == 13
          val = $("#Search", @$el).val()
          window.geocoder.geocode address: val, ([result], status) =>
            return unless status = google.maps.GeocoderStatus.OK
            @maps.zoom result.geometry.location, 13
        "click .hunt-btn": ->

    initialize: (coordinates) =>
      $("body").addClass("fullscreen") if window.location.hash == "#fullscreen"
      $("input[type=time]").timepicker
        minuteStep: 1
        showMeridian: false
      for group in window.fox_groups
        $(".fox-group-select").append $ """<option value="#{group}">#{group.charAt(0).toUpperCase() + group.slice(1)}</option>"""
      $("#huntForm .clear-btn").on "click", ->
        $(".fox-group-select").find("option:first").attr("selected", true)
        $(".location-input").val("")
      $("#huntForm .create-btn").on "click", ->
        [hour, minute] = (+x for x in $(".time-input").val().split(/:/))
        data =
          found_at: new Date(2012, 21, 10, hour, minute, 0).getTime()
          fox_group: $(".fox-group-select").val()
          raw: $(".location-input").val()
        save = ->
            window.hunts.create data
        if /\d+(\.\d+)?[, ;]+\d+(\.\d+)?/.test data.raw
          save()
        else
          window.geocoder.geocode address: data.raw, (results, status) ->
            return unless status == google.maps.GeocoderStatus.OK
            data.raw = "#{results[0].geometry.location.lat()} #{results[0].geometry.location.lng()}"
            save()
      $(".smaller-btn").click ->
        zoom *= 0.9
        $("body").animate zoom: "#{zoom}%", "fast"
      $(".larger-btn").click ->
        zoom /= 0.9
        $("body").animate zoom: "#{zoom}%", "fast"

      @maps = new views.Maps window.hints, window.hunts
      @hints = new views.Hints window.hints, @maps
      first = $("#hour-#{Math.floor(window.MapTime(Date.now()).ToHour())}")
      $("tbody").animate({scrollTop: first.offset().top - $("#hour-0").offset().top - 20 }, "slow") if first.length
