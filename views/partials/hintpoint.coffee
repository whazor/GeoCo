coffeescript -> $ ->
  popup = new Popup $('.hintpoint'), 'vertical', '5px 1px'
  window.hintClick = (e) ->
    id = $(this).data 'id'
    popup.show $(this), (selector) =>
      selector.css zIndex: 40000
      console.log "/hint/#{id}"
      $.get "/hint/#{id}", (r) ->
        $('.content', selector).html r
        popup.position()
    return false

  # Popup opener
  timeout = false
  autoposition = (event) ->
    clearTimeout timeout
    timeout = setTimeout (-> popup.position()), 150
  #$('#hints tbody').bind 'scroll', autoposition
  $(window).bind 'resize', autoposition

div '.hintpoint.hidden', ->
  h3 '.title', -> 'Hint'
  div '.modal-body.content.clearfix', ->
    img src: '/img/spinner.gif', style: 'display:block;float:left;'
    div style: 'margin-left: 25px;', -> 'Laden...'

  div '.modal-footer', ->
    button '.btn.cancel.primary', -> 'Sluiten'


