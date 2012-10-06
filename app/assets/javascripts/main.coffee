$ -> 
	mapOptions =
	    zoom: 13,
	    mapTypeId: google.maps.MapTypeId.ROADMAP
	map = new google.maps.Map(document.getElementById('maps'), mapOptions)
	
	allowedBounds = new google.maps.LatLngBounds(
		new google.maps.LatLng(51.7337, 4.9937),
		new google.maps.LatLng(52.5219, 6.8330)
	)
	map.fitBounds(allowedBounds)
	lastValidCenter = map.getCenter()
	
	layer = null
	google.maps.event.addListener map, 'click', (e) =>
		$.getJSON "/route/#{e.latLng.lng()}/#{e.latLng.lat()}", (json) =>
			#if(layer != null)
			#	layer.setMap(null)
#			json =
#				type: "GeometryCollection",
#				geometries: data

			lineCoordinates = (new google.maps.LatLng(geometry[1], geometry[0]) for geometry in json.geometries)
			
			layer = new google.maps.Polyline(
				path: lineCoordinates
				strokeColor: "#FFFF00",
				strokeWeight: 10,
				strokeOpacity: 1
			)
			layer.setMap(map)
			
				
			
		
	
	google.maps.event.addListener map, 'center_changed', ->
		if (allowedBounds.contains(map.getCenter()))
		  lastValidCenter = map.getCenter()
		  return
		map.panTo(lastValidCenter)