@views ||= {}
class @views.Dashboard extends Backbone.View
    el: '#app'
    events:
        "click .brand": -> false,
        "keydown #Search": (e) ->
          return unless e.keyCode == 13
          val = $("#Search", @$el).val()
          window.geocoder.geocode address: val, ([result], status) =>
            return unless status = google.maps.GeocoderStatus.OK
            @maps.zoom result.geometry.location, 13
    initialize: (coordinates) =>
      $("body").addClass("fullscreen") if window.location.hash == "#fullscreen"
      @maps = new views.Maps window.hints, window.hunts
      @hints = new views.Hints window.hints, @maps
      $("tbody").animate({scrollTop: $("#hour-#{Math.floor(window.MapTime(Date.now()).ToHour())}").offset().top - $("#hour-0").offset().top - 20 }, "slow")