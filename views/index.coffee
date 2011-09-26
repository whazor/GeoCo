doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title 'GeoCo'

    link rel: 'stylesheet', href: '/css/master.css'

    script src:"/js/jquery-1.6.4.min.js"
    script src:"/js/bootstrap-dropdown.js"
    script src:"/js/polymaps.min.js"
    script src:"/browserify.js"
  body ->
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
          table '.zebra-striped', ->
            tr ->
              th 'Tijd:'
              th '.blue',-> 'Alpha'
              th '.purple',-> 'Bravo'
              th '.orange',-> 'Charlie'
              th '.yellow',-> 'Delta'
              th '.red',-> 'Foxtrot'
              th '.green',-> 'Echo'

            btn = -> button '.btn', -> 'Invullen'
            getClaimedBy = ->
              switch Math.floor Math.random() * 6
                when 0 then 'Mark'
                when 1 then 'Nanne'
                when 2 then 'Lex'
                when 3,4,5 then btn()
            for i in [0..10]
              tr style: 'height: 48px', ->
                td -> "#{12+i}:00"
                td -> getClaimedBy()
                td -> getClaimedBy()
                td -> getClaimedBy()
                td -> getClaimedBy()
                td -> getClaimedBy()
                td -> getClaimedBy()
