x=0;y=0;l=0,f=0;a=" ";b="  ";xx="";yy=" "
f1="0";f2="0";f3="0";gra=0;min=0;sec=0

function Grad(graden)
{
  g0 = graden
  gra = Math.floor(g0)
  g0 =(g0 - gra) * 60
  min = Math.floor(g0)
  sec =Math.round((g0 - min) * 60*1000)/1000
  if (sec==60) {min=min+1; sec=0}
  if (min==60) {gra=gra+1; min=0}
}
function Convert(x, y, tijd, name)
{
  // x=parseFloat(obj.xx.value)
  // y=parseFloat(obj.yy.value)
  if (x<1000) x*=1000
	else if (x.toString().length<=5) x*=10
	
  if (y<1000) y*=1000
	else if (y.toString().length<=5) y*=10	
	// if (x<10000) x*=1000
	//   if (y<10000) y*=1000
  if (x<0 || x>290000){
		// alert("te kort 1!"+x.toString());
		// x *= 5 - Math.floor(Math.log(x));
	}else
  {
    if (y<290000 || y>630000){
		// alert("te kort 2!"+y.toString());
			}else
      RDLatLong(x,y, tijd, name)
  }
}
function RDLatLong(x,y, tijd, name)
{
  x0  = 155000.000
  y0  = 463000.000
  f0 = 52.156160556
  l0 =  5.387638889
  a01=3236.0331637 ; b10=5261.3028966
  a20= -32.5915821 ; b11= 105.9780241
  a02=  -0.2472814 ; b12=   2.4576469
  a21=  -0.8501341 ; b30=  -0.8192156
  a03=  -0.0655238 ; b31=  -0.0560092
  a22=  -0.0171137 ; b13=   0.0560089
  a40=   0.0052771 ; b32=  -0.0025614
  a23=  -0.0003859 ; b14=   0.0012770
  a41=   0.0003314 ; b50=   0.0002574
  a04=   0.0000371 ; b33=  -0.0000973
  a42=   0.0000143 ; b51=   0.0000293
  a24=  -0.0000090 ; b15=   0.0000291
  with(Math){
    dx=(x-x0)*pow(10,-5);
    dy=(y-y0)*pow(10,-5);
    df =a01*dy + a20*pow(dx,2) + a02*pow(dy,2) + a21*pow(dx,2)*dy + a03*pow(dy,3)
    df+=a40*pow(dx,4) + a22*pow(dx,2)*pow(dy,2) + a04*pow(dy,4) + a41*pow(dx,4)*dy
    df+=a23*pow(dx,2)*pow(dy,3) + a42*pow(dx,4)*pow(dy,2) + a24*pow(dx,2)*pow(dy,4);
    f = f0 + df/3600;
    dl =b10*dx +b11*dx*dy +b30*pow(dx,3) + b12*dx*pow(dy,2) + b31*pow(dx,3)*dy;
    dl+=b13*dx*pow(dy,3)+b50*pow(dx,5) + b32*pow(dx,3)*pow(dy,2) + b14*dx*pow(dy,4);
    dl+=b51*pow(dx,5)*dy +b33*pow(dx,3)*pow(dy,3) + b15*dx*pow(dy,5);
    l = l0 + dl/3600
  }
  RdWgs84(f,l, tijd, name)
}
function pr (f)
{
  return ((f>0.0)&&(f<10.0))?"0" + f:f;
}
function RdWgs84(f,l, tijd, name)
{
  fWgs=f+(-96.862-11.714*(f-52)-0.125*(l-5))/100000;
  lWgs=l+(-37.902+0.329*(f-52)-14.667*(l-5))/100000;
  fWgs0 = fWgs;
  fWgs1 = Math.floor(fWgs);
  fWgs0 =(fWgs0 - fWgs1) * 60;
  fWgs2 = Math.floor(fWgs0);
  fWgs3 =Math.round((fWgs0 - fWgs2) * 60*1000)/1000;
  if (fWgs3==60) {fWgs2+=1; fWgs3=0};
  if (fWgs2==60) {fWgs1+=1; fWgs2=0};
  // obj.fWgs1.value=fWgs1;
  // obj.fWgs2.value=pr(fWgs2);
  // obj.fWgs3.value=pr(fWgs3);
  

  lWgs0 = lWgs;
  lWgs1 = Math.floor(lWgs);
  lWgs0 =(lWgs0 - lWgs1) * 60;
  lWgs2 = Math.floor(lWgs0);
  lWgs3 =Math.round((lWgs0 - lWgs2) * 60*1000)/1000;
  if (lWgs3==60) {lWgs2+=1; lWgs3=0};
  if (lWgs2==60) {lWgs1+=1; lWgs2=0};
	var cordx = fWgs;
	var cordy = lWgs;
	
	placeMarker(cordx, cordy, tijd, name)
}
markers = [];
allCords = [];
paths = [];
function placeMarker(x,y, tijd, name){
	var icon = (name == "x" ? "/images/maps-vossen-icons-x.png" : "/images/maps-vossen.png");
	var cm = new google.maps.Marker({
		title: name + ": " + tijd,
		position: new google.maps.LatLng(x, y),
		map: map,
		icon: new google.maps.MarkerImage(icon, null, null, new google.maps.Point(14, 14))
	});
	allCords[name] = allCords[name] || [];
	allCords[name].push(new google.maps.LatLng(x, y));
	markers.push(cm);
	
	
	/*var tijdWindow = new google.maps.InfoWindow({content: name+": "+tijd});
	console.log(name+": "+x+" "+y);
	google.maps.event.addListener(cm, "mouseover", function() { tijdWindow.open(map, cm) });
	google.maps.event.addListener(cm, "mouseout", function() { tijdWindow.close(map, cm) });*/
};
//-->


String.prototype.trim = function() {
	return this;
}
function doSomething(root){
	for (var i=0; i < markers.length; i++) {
		markers[i].setMap(null);
	};
	markers = [];
	allCords = [];
	for (var i=0; i < paths.length; i++) {
		paths[i].setMap(null);
	};
	paths = [];
	var feed = root.feed;
	for (var i = 0; i < feed.entry.length; i++) {
		var entry = feed.entry[i];
		var title = entry.title.$t;
		var content = entry.content.$t.split(", ");
		var data = {};
		for(var z in content) {
			var splitted = content[z].split(": ");
			data[splitted[0]] = splitted[1];
		}
		for(var p in data) {
			if(p == "tijden") continue;
			var splitted = data[p].replace(" ", "").split(";");
			data[p] = { "x": splitted[0], "y": splitted[1] };
			
		}
		for (var team in data) {
			if(!data[team].x) continue;
			// if (!data[team].x.match(/^\s*\d{5}\s*;\s*\d{5}\s*$/).length > 1) {
			// 	placeMarker(data[team].x, data[team].y, data["tijden"], team);
			// } else {
			// 	Convert(data[team].x, data[team].y, data["tijden"], team);
			// };
			if (data[team].x.split(".").length > 1 || data[team].y.split(".").length > 1) {
				placeMarker(data[team].x, data[team].y, data["tijden"], team);
			} else {
				Convert(data[team].x, data[team].y, data["tijden"], team);
			};
			
		};
		for (var thing in allCords) {
			for (var cordi=0; cordi < allCords[thing].length; cordi++) {
				if (cordi < (allCords[thing].length-1)) {
					polyline = new google.maps.Polyline({
				    path: [allCords[thing][cordi], allCords[thing][cordi+1]],
				    strokeColor: "#FF0000",
				    strokeOpacity: 1.0,
				    strokeWeight: 2
				  });
					polyline.setMap(map);
					paths.push(polyline);	
				};
			};
		};
	}
};
$(function(){
	var cachingthing = 0;
	function getCords() {
		$("#javascripts").html('<script src="http://spreadsheets.google.com/feeds/list/tGmiwetlm27t45ESdPOQCYg/od6/public/basic?alt=json-in-script&callback=doSomething&emptyvar='+cachingthing+'" type="text/javascript"></script>');
		// $.get("http://spreadsheets.google.com/feeds/list/tGmiwetlm27t45ESdPOQCYg/od6/public/basic?alt=json", function(data){
		// 	for(var entry in data.feed.entry) {
		// 		var blaat = entry.content["$t"];
		// 		alert(blaat);
		// 	}
		// 	
		// });
		cachingthing++;
		// setTimeout(function() {
		// 	getCords();
		// }, 10000);
	};
	getCords();
	
});
