@views ||= {}
m = google.maps
window.geocoder = new m.Geocoder()
class @views.Maps extends Backbone.View
  deelgebieden = {}
  groupMarkers = []
  window.data = {}
  el: '#maps'
  initialize: (@hints, @hunts) ->
    window.Clock.listeners.push ->
      for name, gData of data
        gData.poly.setPath gData.collection.map (model) -> new m.LatLng model.get("lat"), model.get "lng"
        if gData.collection.length != 0
          model = gData.collection.at(gData.collection.length - 1)
          gData.marker.setPosition(new google.maps.LatLng model.get("lat"), model.get "lng")
      return

    @$el = $(@el)
    window.map = new m.Map @el,
        zoom: 13,
        mapTypeId: m.MapTypeId.ROADMAP
    allowedBounds = new m.LatLngBounds new m.LatLng(51.7337, 4.9937), new m.LatLng(52.5219, 6.8330)
    map.fitBounds(allowedBounds)
    lastValidCenter = map.getCenter()

    google.maps.event.addListener map, 'center_changed', ->
        if not allowedBounds.contains(map.getCenter())
          map.panTo(lastValidCenter)
          return
        lastValidCenter = map.getCenter()

    $.getJSON "/assets/javascripts/deelgebied.json", (json) =>
      for name, data of json
        p = new m.Polygon
          paths: new m.LatLng(lat, lng) for {lat, lng} in data.points,
          strokeColor: data.color,
          strokeOpacity: 0.8,
          strokeWeight: 2,
          fillColor: data.color,
          fillOpacity: 0.05
        p.setMap(map)
      deelgebieden[name] = poly: p, points: data.points
    $.get "/assets/kml/groepen.kml", (raw) ->
      kml = $ raw
      $("Placemark", kml).each ->
        mark = $(this)
        name = $("name", mark).text()
        [lng, lat] = (parseFloat x for x in $("Point coordinates", mark).text().split(/,/))
        pos = new google.maps.LatLng lat, lng
        groupMarkers.push
          marker: new m.Marker
            position: pos
            map: map
            icon:
              path: google.maps.SymbolPath.CIRCLE
              strokeColor: "#11BB11"
              strokeOpacity: 0
              fillColor: "#11BB11"
              fillOpacity: 0.8
              strokeWeight: 1
              scale: 3
            title: "#{name}: #{lat}, #{lng}"
          circle: new m.Circle
            center: pos
            map: map
            radius: 500
            strokeColor: "#11BB11"
            strokeOpacity: 0.8
            fillColor: "#11BB11"
            fillOpacity: 0.1
            strokeWeight: 1


    for group in window.fox_groups
      gData = data[group] =
        collection: new Backbone.Collection
        name: group
        poly: new m.Polyline
          path: []
          strokeColor: window.fox_colors[group]
          strokeOpacity: 1.0
          strokeWeight: 2
          map: map
        marker: new m.Marker
          map: map
          icon: "/assets/img/marker_#{group.charAt(0).toUpperCase()}.png"
      gData.collection.comperator = (coord) -> coord.time ? 0
      gData.collection.on "change", ->
        gData.poly.setPath gData.collection.map (model) -> new m.LatLng model.get("lat"), model.get "lng"
      gData.collection.on "add", ->
        gData.poly.setPath gData.collection.map (model) -> new m.LatLng model.get("lat"), model.get "lng"
      gData.collection.on "remove", ->
        gData.poly.setPath gData.collection.map (model) -> new m.LatLng model.get("lat"), model.get "lng"
      gData.collection.on "reset", ->
        gData.poly.setPath gData.collection.map (model) -> new m.LatLng model.get("lat"), model.get "lng"
      gData.collection.reset @hints.where fox_group: group
      gData.collection.add @hunts.where fox_group: group

    @hints.on "add", (hint) ->
      data[hint.get "fox_group"].collection.add hint
    @hunts.on "add", (hunt) ->
      data[hunt.get "fox_group"].collection.add hunt
    @hints.on "remove", (hint) ->
      data[hint.get "fox_group"].collection.remove(hint)
    @hunts.on "remove", (hunt) ->
      data[hunt.get "fox_group"].collection.remove(hunt)
    @hints.on "reset", ->
      for name, gData of data
        gData.collection.reset @hints.where fox_group: name
        gData.collection.add @hunts.where fox_group: name
    @hunts.on "reset", ->
      for name, gData of data
        gData.collection.reset @hints.where fox_group: name
        gData.collection.add @hunts.where fox_group: name