@views ||= {}
m = google.maps
window.geocoder = new m.Geocoder()
class @views.Maps extends Backbone.View
  deelgebieden = {}
  data = {}
  el: '#maps'
  initialize: (@hints, @hunts) ->
    @$el = $(@el)
    map = new m.Map @el,
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

    $.getJSON "/assets/javascripts/deelgebied.json", (json) ->
      for name, data of json
        p = new m.Polygon
          paths: new m.LatLng(lat, lng) for {lat, lng} in data.points,
          strokeColor: window.fox_colors[name],
          strokeOpacity: 0.8,
          strokeWeight: 2,
          fillColor: window.fox_colors[name],
          fillOpacity: 0.05
        p.setMap(map)
      deelgebieden[name] = poly: p, points: data.points

    for group in window.fox_groups
      gData = data[group] =
        collection: new Backbone.Collection
        name: group
        poly: new m.Polyline
          paths: []
          strokeColor: window.fox_colors[name],
          strokeOpacity: 0.8,
          strokeWeight: 2,
      gData.poly.setMap map
      gData.collection.comperator = (coord) -> coord.time ? 0
      gData.collection.on "change", ->
        gData.poly.setPath = gData.collection.map (model) -> new m.LatLng model.get "lat", model.get "lng"

    @hints.on "add", (hint) ->
      data[hint.get "fox_group"].collection.add hint
    @hunts.on "add", (hunt) ->
      data[hunt.get "fox_group"].collection.add hunt
    @hints.on "remove", (hint) ->
      data[hint.get "fox_group"].collection.remove(model)
    @hunts.on "remove", (hunt) ->
      data[hunt.get "fox_group"].collection.remove(model)
    @hints.on "reset", ->
      for gData, name of data
        gData.collection.reset @hint.where fox_group: name
        gData.collection.add @hunt.where fox_group: name
    @hunts.on "reset", ->
      for gData, name of data
        gData.collection.reset @hint.where fox_group: name
        gData.collection.add @hunt.where fox_group: name