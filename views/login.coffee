coffeescript ->
  $ ->
    if window.location.hash == '#fail'
      $('#password').addClass 'error'

    map.zoom 9.5
div '#map.full.buttonless.background', ->
div '.modal-backdrop', ->

div '#modal.modal', ->
  div '.modal-header', ->
    h4 style: 'float:right', -> 'GeoCo'
    h3 'Inloggen'

  form '.form-stacked', style: 'padding:0;margin:0', method: 'post', action: '/authenticate', ->
    div '.modal-body', ->
      div '#username.clearfix', ->
        label 'Jouw naam:'
        input name: 'name', type: 'text'

      div '#password.clearfix', ->
        label 'Site wachtwoord:'
        input name: 'password', type: 'password'
    div '.modal-footer', ->
      button '.btn.primary', -> 'Inloggen'
