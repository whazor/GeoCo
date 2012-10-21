@views ||= {}
m = google.maps
window.geocoder = new m.Geocoder()
class @views.Maps extends Backbone.View
  window.data = {}
  el: '#maps'
  initialize: (@hints, @hunts) ->
    @deelgebieden = {}
    @markers = []
    @collection = {}
    @timeout = null
    @paths = {}

    @$el = $(@el)
    @map = new m.Map @el,
        zoom: 13,
        mapTypeId: m.MapTypeId.ROADMAP
        scaleControl: true
    allowedBounds = new m.LatLngBounds new m.LatLng(51.7337, 4.9937), new m.LatLng(52.5219, 6.8330)
    @map.fitBounds allowedBounds
    lastValidCenter = @map.getCenter()

    m.event.addListener @map, 'center_changed', =>
      if not allowedBounds.contains @map.getCenter()
        @map.panTo lastValidCenter
        return
      lastValidCenter = @map.getCenter()

    @getDeelgebieden()
    @getGroepen()

    for group in fox_groups
      @collection[group] = []
      @paths[group] = new m.Polyline
        path: []
        strokeColor: window.fox_colors[group]
        strokeOpacity: 1.0
        strokeWeight: 2
      @paths[group].setMap @map


    addModel = (model) =>
      group = model.get 'fox_group'
      insert = false
      for m, i in @collection[group]
        if model.get('time') < m.get ('time')
          @collection[group].splice(i, 0, model)
          insert = true
          break
      @collection[group].push(model) if not insert
      clearInterval @timeout
      @timeout = setTimeout (=> @render()), 400
    @hints.on "add", addModel
    @hunts.on "add", addModel
    changeModel = (model) =>
      clearInterval @timeout
      @timeout = setTimeout (=> @render()), 400
      @drawModel model
    @hints.on "change", changeModel
    @hunts.on "change", changeModel
    removeModel = (model) =>
      clearInterval @timeout
      group = model.get 'fox_group'
      for m, i in @collection[group] when m == model
        @collection[group].splice(i, 1)
      @timeout = setTimeout (=> @render()), 400
    @hints.on "remove", removeModel
    @hunts.on "remove", removeModel

  drawModel: (model) =>
    group = model.get 'fox_group'
    @markers[group].setMap(null) if @markers[group]
    @markers[group] = new m.Marker
      position: new m.LatLng model.get("lat"), model.get("lng")
      map: @map
      icon: "/assets/img/marker_#{group.charAt(0).toUpperCase()}.png"
      title: new Date(model.get("time")).toLocaleTimeString().slice(0, 5)
    @markers[group].setMap @map

  render: =>
    for group in window.fox_groups when @collection[group] != null and @collection[group].length > 0
      model = @collection[group][@collection[group].length - 1]
      @drawModel model
      @paths[group].setPath (new m.LatLng(model.get('lat'), model.get('lng')) for model in @collection[group])
    @

  zoom: (location, zoom) ->
    @map.setCenter location
    @map.setZoom zoom

  getDeelgebieden: =>
    $.getJSON "/assets/javascripts/deelgebied.json", (json) =>
      for name, data of json
        p = new m.Polygon
          paths: new m.LatLng(lat, lng) for {lat, lng} in data.points,
          strokeColor: data.color,
          strokeOpacity: 0.8,
          strokeWeight: 2,
          fillColor: data.color,
          fillOpacity: 0.05
        p.setMap @map
      @deelgebieden[name] = poly: p, points: data.points

  getGroepen: =>
    $.get "/assets/kml/groepen.kml", (raw) =>
      kml = $ raw
      $("Placemark", kml).each (i, mark) =>
        name = $("name", mark).text()
        [lng, lat] = (parseFloat x for x in $("Point coordinates", mark).text().split(/,/))
        pos = new m.LatLng lat, lng
        s = new m.Marker
          position: pos
          icon:
            path: m.SymbolPath.CIRCLE
            strokeColor: "#11BB11"
            strokeOpacity: 0
            fillColor: "#11BB11"
            fillOpacity: 0.8
            strokeWeight: 1
            scale: 3
          title: "#{name}: #{lat}, #{lng}"
        s.setMap @map
        c = new m.Circle
          center: pos
          radius: 500
          strokeColor: "#11BB11"
          strokeOpacity: 0.8
          fillColor: "#11BB11"
          fillOpacity: 0.1
          strokeWeight: 1
        c.setMap @map