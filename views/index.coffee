# Topbar
div '.topbar', ->
  div '.topbar-inner', ->
    div '.container', ->
      a '.brand', -> 'jotihunt.mycel.nl'
      ul '.nav', ->
        li -> a href: '/',-> '2011'
        li -> a href: '/?#2010',-> '2010'
      ul '.pull-right.nav.secondary-nav', ->
        li '.dropdown', ->
          a '.dropdown-toggle', -> @username
          ul '.dropdown-menu', ->
            li -> a href: '/logout', -> 'Uitloggen'

# Popup
partial 'partials/hintform'
partial 'partials/hintpoint'

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


        btn = (group, i) ->
          button '.btn', 'data-group': group, 'data-time': 1+i, -> 'Invullen'
        tbody style: 'height: 569px', ->
          for i in [0..29]
            tr style: 'height: 48px', ->
              td '.width', -> btn 'Alpha', i
              td '.width', -> btn 'Bravo', i
              td '.width', -> btn 'Charlie', i
              td '.width', -> btn 'Delta', i
              td '.width', -> btn 'Echo', i
              td '.width', -> btn 'Foxtrot', i
              td '.full-width', -> "#{(9+i) % 24}:00" # HACK
