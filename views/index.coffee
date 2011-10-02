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
div '.hintform.popover.left', style: 'z-index: 10001', ->
  div '.arrow', ->
  div '.inner', ->
    h3 '.title', -> 'Alpha - 14:00'
    form '.form-stacked.content', style: 'padding:0;margin:0', method: 'post', action: '/hints', ->
      div '.modal-body', ->
        label 'Soort:'
        select ->
          option 'Rijksdriehoekscoördinaten'
          option 'Geografische coördinaten'
          option 'Adres'
        label 'Coördinaat:'
        input '.mini', maxlength: 6

        span ','
        input '.mini', maxlength: 6
        span ' '
        button '.btn.small', -> 'Inactief'
      div '.modal-footer', ->
        button '.btn.primary', -> 'Toevoegen'
        button '.btn.cancel', -> 'Annuleren'

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
          th '.width.green',-> 'Echo'
          th '.width.red',-> 'Foxtrot'
          th '.full-width', -> 'Tijd:'

      coffeescript ->
        $ ->
          $('.btn').bind 'click', ->
            form = $ '.hintform'
            form.show()
            form.position
              of: $ this
              my: 'left center'
              at: 'right center'
              offset: ''
              collision: 'flip flip'
            form.toggleClass 'left', form.hasClass('ui-flipped-left')
            form.toggleClass 'right', !form.hasClass('ui-flipped-left')
            i = parseInt $(this).data('time') - 1
            $('.hintform .cancel').bind 'click', (event) ->
              event.preventDefault()
              $('.hintform').hide()
            $('.hintform .title').text("#{$(this).data('group')} - #{(9+i) % 24}:00")
            console.log $(this).data('time')
            #alert 'test'
      table '.zebra-striped.scroll.scroll-body', ->
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
