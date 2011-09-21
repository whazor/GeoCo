
var po,map;
$(function(){
  $('.topbar').dropdown();

  po = org.polymaps;
  map = po.map()
    .container(document.getElementById("map").appendChild(po.svg("svg")))
    .add(po.interact())
    .center({lat: 52.1, lon: 5.924377})
    .zoom(9);

  map.add(po.image()
      .url(po.url("http://{S}tile.cloudmade.com/60f28d6eca2e43828b5eccb000f2e226/1/256/{Z}/{X}/{Y}.png")
      .hosts(["a.", "b.", "c.", ""])));


  map.add(po.compass().pan("none"));
  function load(e) {
    for (var i = 0; i < e.features.length; i++) {
      var feature = e.features[i];
      feature.element.setAttribute("class", "group "+feature.data.id);
    }
  }

  // Laat deelgebieden zien.
  map.add(
    po.geoJson().url("/deelgebieden.json").on("load", load)
  );

  function d(){
    if(b=!b){
      a.css("position","fixed").css("right","16px").css("top","16px");
      a.find('.arrow').attr("transform","translate(16,16)rotate(135)scale(5)translate(-1.85,0)");
    }else{
      console.log('ding');
      a.css("position","absolute").css("right","-16px").css("top","-16px");
      a.find('.arrow').attr("transform","translate(16,16)rotate(-45)scale(5)translate(-1.85,0)");
    }
    $('.topbar').toggleClass('hidden', b);
    $('#map').toggleClass('full', b);
    map.resize()
  }
  var f=$(document.body);
  var c=$("#map");
  var b=false;
  var a = $('\
    <svg style="position: absolute; right: -16px; top: -16px; width: 32px; height: 32px; ">\
      <circle cx="16" cy="16" r="14" fill="#fff" stroke="#ccc" stroke-width="4" />\
      <path class="arrow" transform="translate(16,16)rotate(-45)scale(5)translate(-1.85,0)" d="M0,0L0,.5 2,.5 2,1.5 4,0 2,-1.5 2,-.5 0,-.5Z" pointer-events="none" fill="#aaa" />\
    </svg>');
  a.bind("mousedown",d);
  c.append(a);
  //a.append($("<svg:title>Uit fullscreen gaan (ESC)</svg:title>"));
  window.addEventListener("keydown",function(g){g.keyCode==27&&b&&d()},false)
});
