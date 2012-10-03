$(function() {
	L.Icon.Default.imagePath = "/assets/images";

	var local = L.tileLayer('/tiles/{z}/{x}/{y}.png', {
	    maxZoom: 18
	});
	
	var osm = L.tileLayer('http://{s}.tile.cloudmade.com/2134bf4959a749c2af54d7839679a80a/997/256/{z}/{x}/{y}.png');
	
	var map = L.map('map', {
		layers: [local]
	}).setView([52.1, 5.924377], 8);
	L.control.layers({"OSM": osm, "Lokaal": local}, null).addTo(map);
	var margin = 0.75,
	southWest = new L.LatLng(51.7337 - margin, 4.9937 - margin),
    northEast = new L.LatLng(52.5219 + margin,6.8330 + margin),
    bounds = new L.LatLngBounds(southWest, northEast);
	
	map.setMaxBounds(bounds);
//	map.panInsideBounds(bounds);
	
	var geoJSON = null;
	var marker = null;
	map.on('click', function(e) {
		if(marker != null) map.removeLayer(marker);
		marker = L.marker(e.latlng);
		map.addLayer(marker);
		$.getJSON("/geo/"+e.latlng.lat+"/"+e.latlng.lng, function(data) {
			if(geoJSON != null) map.removeLayer(geoJSON);
			geoJSON = L.geoJson(data, {style: {color: "green"}});
			map.addLayer(geoJSON);
		});
	});
});