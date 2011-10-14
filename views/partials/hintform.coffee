coffeescript -> $ ->
  popup = new Popup $ '.hintform'
  # Popup opener
  $('#hints .btn').bind 'click', ->
    return unless $(this).data('group')

    popup.show $(this), (selector) =>
      time = new Date()
      time.setTime parseInt($(this).data('time'))
      group = $(this).data 'group'

      formatted = time.toLocaleTimeString().substring 0, 5

      $('.title', selector).text "#{group} - #{formatted}:00"
      $('[name=fox_group]', selector).val group
      $('[name=time]', selector).val time.getTime()

      # Rest of the javascript
      $('.hinttype', selector).bind 'change', (event) ->
        none = $(this).val() == 'none'
        $('.rdh').toggleClass 'hidden', $(this).val() != 'rdh' or none
        $('.longlat').toggleClass 'hidden', $(this).val() != 'longlat' or none
        $('.address').toggleClass 'hidden', $(this).val() != 'address' or none
        popup.position()

      changeCord = false
      $('.cord', selector).bind 'keyup', (event) ->
        sort = $('[name=sort]', selector).val()
        [x, y] = [0, 0]

        switch sort
          #when 'address'
          when 'longlat'
            x = parseFloat $('[name=longlat_x]', selector).val()
            y = parseFloat $('[name=longlat_y]', selector).val()
          when 'rdh'
            cordx = $('[name=rdh_x]', selector).val()
            cordy = $('[name=rdh_y]', selector).val()
            t = new Cords.Triangular cordx, cordy
            g = t.toGeographic()
            [x, y] = [g.x, g.y]
        console.log [x, y]
        point.features([{geometry: {coordinates: [y, x], type: "Point"}}])
        #point.
        #autoposition = (event) ->
          #clearTimeout timeout
          #timeout = setTimeout (-> popup.position()), 50


  timeout = false
  autoposition = (event) ->
    clearTimeout timeout
    timeout = setTimeout (-> popup.position()), 50
  $('#hints tbody').bind 'scroll', autoposition
  $(window).bind 'resize', autoposition

div '.hintform.hidden', ->
  h3 '.title', -> 'Popup'
  form '.form-stacked.content', style: 'padding:0;margin:0', method: 'post', action: '/hints', ->
    div '.modal-body', ->
      input name: 'fox_group', type: 'hidden'
      input name: 'time', type: 'hidden'
      label 'Soort:'
      select '.hinttype', name: 'sort', ->
        option value: 'rdh', -> 'Rijksdriehoekscoördinaten'
        option value: 'longlat', -> 'Geografische coördinaten'
        option value: 'address', -> 'Adres'
        option value: 'none', -> 'Geen'
      div '.rdh', ->
        label 'Coördinaat:'
        input '.mini.cord', name: 'rdh_x', maxlength: 6

        span ','
        input '.mini.cord', name: 'rdh_y', maxlength: 6
      div '.longlat.hidden', ->
        label 'Coördinaat:'
        input '.small.cord', name: 'longlat_x', maxlength: 12

        span ','
        input '.small.cord', name: 'longlat_y', maxlength: 12
      div '.address.hidden', ->
        label 'Adres:'
        input name: 'address', type: 'text'


    div '.modal-footer', ->
      button '.btn.primary', -> 'Toevoegen'
      button '.btn.cancel', -> 'Annuleren'

