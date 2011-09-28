# Topbar
div '.topbar', ->
  div '.topbar-inner', ->
    div '.container', ->
      a '.brand', -> 'jotihunt.mycel.nl'
      ul '.nav', ->
        li -> a '2011'
        li -> a '2010'
      ul '.pull-right.nav.secondary-nav', ->
        li '.dropdown', ->
          a '.dropdown-toggle', -> 'Gast'
          ul '.dropdown-menu', ->
            li -> a 'Verander je naam'
# Rest van de site
div '.container.page', ->
  div '.row', ->
    div '#mapholder.span9', -> div('.content', -> div '#map', ->)
    div '#tableholder.span11', ->
      style '.width { width: 97px; } .full-width { width: 45px }'
      table '.scroll.scroll-head', ->
        tr ->
          th '.width.blue',-> 'Alpha'
          th '.width.purple',-> 'Bravo'
          th '.width.orange',-> 'Charlie'
          th '.width.yellow',-> 'Delta'
          th '.width.red',-> 'Foxtrot'
          th '.width.green',-> 'Echo'
          th '.full-width', -> 'Tijd:'

      table '.zebra-striped.scroll.scroll-body', ->
        btn = -> button '.btn', -> 'Invullen'
        getClaimedBy = ->
          switch Math.floor Math.random() * 6
            when 0 then 'Mark'
            when 1 then 'Nanne'
            when 2 then 'Lex'
            when 3,4,5 then btn()
        tbody style: 'height: 569px', ->
          for i in [0..29]
            tr style: 'height: 48px', ->
              td '.width', -> getClaimedBy()
              td '.width', -> getClaimedBy()
              td '.width', -> getClaimedBy()
              td '.width', -> getClaimedBy()
              td '.width', -> getClaimedBy()
              td '.width', -> getClaimedBy()
              td '.full-width', -> "#{(9+i) % 24}:00" # HACK
