<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
		"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"> 
 
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"> 
	<head> 
		<title>Kaart</title> 
		<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&amp;region=NL"></script>
		<style type="text/css" media="screen"> 
			* {
				margin: 0;
				padding: 0;
			}
			body {
				font: 75% "Lucida Grande", "Trebuchet MS", Verdana, sans-serif;
			}
			#map {
				position: absolute;
				top: <?php echo isset($_GET["newmap"]) ? 260 : 0; ?>px;
				bottom: 0;
				left: 0;
				right: 0;
			}
<?php if(isset($_GET["newmap"])) { ?>
			#url {
				position: absolute;
				top: 240px;
				right: 10px;
				font: 1.5em arial;
				background: black;
			}
			#sheet {
				height: 400px;
				width:100%;
				top:0px;
				margin-top:-140px;
				left:0;
				right:0;
			}
<?php } ?>
		</style> 
	</head>
	<body>
<?php if(isset($_GET["newmap"])) { ?>
	<iframe id="sheet" frameborder="0" src="https://spreadsheets.google.com/ccc?key=0AmTS_hlMxqWPdEdtaXdldGxtMjd0NDVFU2RQT1FDWWc&hl=en_GB&authkey=CL2r2tcO"></iframe>
	<div id="url">
		<a href="https://spreadsheets.google.com/ccc?key=0AmTS_hlMxqWPdEdtaXdldGxtMjd0NDVFU2RQT1FDWWc&hl=en_GB&authkey=CL2r2tcO">Volledig scherm</a>
	</div>
<?php } ?>
	<div id="map"> 
 
	</div> 
	<div id="javascripts">
		
	</div>
	<script src="http://www.google.com/jsapi?key=ABQIAAAAfoWzsnjRiyBPL1z_irJRTRSm0mg88kSBUzLe_RD1l5c6oyoVMRR5p0HiJv44QXpNGMxVBUOKgemAPQ" type="text/javascript"></script>
	<script type="text/javascript" charset="utf-8">
		google.load("jquery", "1.4.3");
	</script>
	<script type="text/javascript" charset="utf-8">
		var myOptions = {
			zoom: 10,
			center: new google.maps.LatLng(51.988263,5.924377),
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			scaleControl: true,
		    mapTypeControl: true,
		    mapTypeControlOptions: {
		      style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR
		    },
			navigationControl: true,
			navigationControlOptions: {
				style: google.maps.NavigationControlStyle.ZOOM_PAN
			}
		};
		var map = new google.maps.Map(document.getElementById("map"), myOptions);
	</script>
	<script src="/oud/groups.js" type="text/javascript" charset="utf-8"></script>
	<script src="/oud/hints.js" type="text/javascript" charset="utf-8"></script>
</body> 
</html>
