@views ||= {}
m = google.maps
class @views.Maps extends Backbone.View
    el: '#maps'
    initialize: ->
        map = new m.Map @el,
            zoom: 13,
            mapTypeId: m.MapTypeId.ROADMAP
        allowedBounds = new m.LatLngBounds new m.LatLng(51.7337, 4.9937), new m.LatLng(52.5219, 6.8330)
        map.fitBounds(allowedBounds)
        lastValidCenter = map.getCenter()
        layer = null
        deelgebieden = {}
        m.event.addListener map, 'click', (e) =>
            $.getJSON "/route/#{e.latLng.lng()}/#{e.latLng.lat()}", (json) =>
                #if(layer != null)
                #	layer.setMap(null)

                lineCoordinates = (new m.LatLng(geometry[1], geometry[0]) for geometry in json.geometries)

                layer = new google.maps.Polyline
                    path: lineCoordinates
                    strokeColor: "#FFFF00",
                    strokeWeight: 10,
                    strokeOpacity: 1
                layer.setMap(map)
        google.maps.event.addListener map, 'center_changed', ->
            if not allowedBounds.contains(map.getCenter())
              map.panTo(lastValidCenter)
              return
            lastValidCenter = map.getCenter()
            ###
        m.event.addListener map, "bounds_changed", ->
          bounds = map.getBounds()
          if bounds?
            ne = bounds.getNorthEast()
            sw = bounds.getSouthWest()
            clamp = (min, max) ->
              if(min > max)
                temp = min
                min = max
                max = temp
              (v) -> Math.max(min, Math.min(max, v))
            clampBounds = (minLat, maxLat, minLng, maxLng) ->
              clampLat = clamp minLat, maxLat
              clampLng = clamp minLng, maxLng
              (lat, lng) -> new m.LatLng(clampLat(lat), clampLng(lng))
            clamper = clampBounds sw.lat(), ne.lat(), sw.lat(), ne.lng()
            for name, gebied of deelgebieden
              gebied.poly.setPath (clamper(lat, lng) for {lat, lng} in gebied.points)
            return
        ###

        $.getJSON "/assets/javascripts/deelgebied.json", (json) ->
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
