# Topbar
div '.topbar', ->
  div '.topbar-inner', ->
    div '.container', ->
      a '.brand', -> 'jotihunt.mycel.nl'
      ul '.nav', ->
        li -> a href: '/mobile',-> 'Mobile'
        #li -> a href: '/?#2010',-> '2010'
      ul '.pull-right.nav.secondary-nav', ->
        li '.dropdown', ->
          a '.dropdown-toggle', -> @username
          ul '.dropdown-menu', ->
            li -> a href: '/logout', -> 'Uitloggen'

# Popup
partial 'partials/hintform'
partial 'partials/hintpoint'

coffeescript -> $ ->
  hints = new Hints $ '#hints'
  hints.redraw()

# Pagina
div '.container.page', ->
  div '.row', ->
    div '#mapholder.span9', -> div('.content', -> div '#map', ->)
    div '#hints.span11', ->
      style '.width { width: 97px; } .full-width { width: 45px }'
      table '.scroll.scroll-head', ->
        thead ->
          tr ->
            th '.width.red',-> 'Alpha'
            th '.width.green',-> 'Bravo'
            th '.width.blueDark',-> 'Charlie'
            th '.width.blue',-> 'Delta'
            th '.width.purple',-> 'Echo'
            th '.width.yellow',-> 'Foxtrot'
            th '.full-width', -> 'Tijd:'


        btn = (group, time) ->
          button '.btn', 'data-group': group, 'data-time': time.getTime(), -> 'Invullen'
        tbody style: 'height: 569px', ->
          for i in [0..@howlong-1]
            time = new Date @begin.getTime() + (i * 3600 * 1000)
            tr style: 'height: 48px', 'data-time': Math.round time.getTime()/1000, ->
              td '.alpha.width', -> btn 'Alpha', time
              td '.bravo.width', -> btn 'Bravo', time
              td '.charlie.width', -> btn 'Charlie', time
              td '.delta.width', -> btn 'Delta', time
              td '.echo.width', -> btn 'Echo', time
              td '.foxtrot.width', -> btn 'Foxtrot', time
              td '.full-width', -> time.toLocaleTimeString().substring 0, 5
