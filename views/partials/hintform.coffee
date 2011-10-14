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
        $('.coordinate').toggleClass 'hidden', $(this).val() == 'address' or none
        $('.address').toggleClass 'hidden', $(this).val() != 'address' or none
        popup.position()

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
      div '.coordinate', ->
        label 'Coördinaat:'
        input '.mini', name: 'cord_x', maxlength: 6

        span ','
        input '.mini', name: 'cord_y', maxlength: 6
      div '.address.hidden', ->
        label 'Adres:'
        input name: 'address', type: 'text'


    div '.modal-footer', ->
      button '.btn.primary', -> 'Toevoegen'
      button '.btn.cancel', -> 'Annuleren'

