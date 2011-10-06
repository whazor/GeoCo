# Hier kunnen requires komen!! :D
window.Popup = require('./popup')
$ ->
  # legacy code:
  $('.topbar').dropdown()

  # Kaart
  buttonless = $('#map').hasClass 'buttonless'
  po = org.polymaps
  window.map = po.map()
    .container($('#map')[0].appendChild(po.svg('svg')))
    .center({lat: 52.1, lon: 5.924377})
    .zoom(9)
  
  unless buttonless
    map.add po.drag()
    map.add po.wheel()
    map.add po.dblclick()
    map.add po.compass().pan("none")

  map.add po.image()
    .url(po.url("http://{S}tile.cloudmade.com/60f28d6eca2e43828b5eccb000f2e226/1/256/{Z}/{X}/{Y}.png")
    .hosts(["a.", "b.", "c.", ""]))


  map.add po.geoJson().url('/deelgebieden.json').on "load", (e) ->
    for feature in e.features
      feature.element.setAttribute('class', "group #{feature.data.id}")

  map.add po.geoJson().url('/hints.json')#.on 'load', (e) ->
  #for feature in e.features
  #  feature.element.setAttribute('class', "group #{feature.data.id}")



  btnMapFullWindow = $ """
  <svg style="position: absolute; right: -16px; top: -16px; width: 32px; height: 32px; ">
      <circle cx="16" cy="16" r="14" fill="#fff" stroke="#ddd" stroke-width="4" />
      <path class="arrow" transform="translate(16,16)rotate(-45)scale(5)translate(-1.85,0)" d="M0,0L0,.5 2,.5 2,1.5 4,0 2,-1.5 2,-.5 0,-.5Z" pointer-events="none" fill="#bbb" />
  </svg>
  """

  isFullWindow = false
  fullWindow = ->
    if(isFullWindow = !isFullWindow)
      btnMapFullWindow.css
        position: 'fixed'
        right: '16px'
        top: '16px'
      btnMapFullWindow.find('.arrow').attr("transform","translate(16,16)rotate(135)scale(5)translate(-1.85,0)")
    else
      btnMapFullWindow.css
        position: 'absolute'
        right: '-16px'
        top: '-16px'
      btnMapFullWindow.find('.arrow').attr("transform","translate(16,16)rotate(-45)scale(5)translate(-1.85,0)")
    $('#map').toggleClass 'full', isFullWindow
    map.resize()

  btnMapFullWindow.bind 'mousedown', fullWindow
  $(window).bind 'keydown', (e) ->
    fullWindow() if e.keyCode == 27 and isFullWindow
    return true

  $('#map').append(btnMapFullWindow) unless buttonless
