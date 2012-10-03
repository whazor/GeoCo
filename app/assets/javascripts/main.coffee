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
	
	google.maps.event.addListener map, 'center_changed', ->
		if (allowedBounds.contains(map.getCenter()))
		  lastValidCenter = map.getCenter()
		  return
		map.panTo(lastValidCenter)