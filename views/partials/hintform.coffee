coffeescript -> $ ->
  popup = new Popup $ '.hintform'
  # Popup opener
  $('#hints .btn').bind 'click', ->
    return unless $(this).data('group')

    popup.show $(this), (selector) =>
      time = 9 + (parseInt $(this).data('time') - 1) % 24
      group = $(this).data 'group'

      $('.title', selector).text "#{group} - #{time}:00"

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

      label 'Soort:'
      select '.hinttype', ->
        option value: 'rdc', -> 'Rijksdriehoekscoördinaten'
        option value: 'latlng', -> 'Geografische coördinaten'
        option value: 'address', -> 'Adres'
        option value: 'none', -> 'Geen'
      div '.coordinate', ->
        label 'Coördinaat:'
        input '.mini', maxlength: 6

        span ','
        input '.mini', maxlength: 6
      div '.address.hidden', ->
        label 'Adres:'
        input type: 'text'


    div '.modal-footer', ->
      button '.btn.primary', -> 'Toevoegen'
      button '.btn.cancel', -> 'Annuleren'
