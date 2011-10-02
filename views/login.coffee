coffeescript -> $ -> map.zoom 9.5
div '#map.full.buttonless', ->
div '.modal-backdrop', ->

div '#modal.modal', ->
  div '.modal-header', ->
    h4 style: 'float:right', -> 'GeoCo'
    h3 'Inloggen'

  form '.form-stacked', style: 'padding:0;margin:0', method: 'post', action: '/authenticate', ->
    div '.modal-body', ->
      label 'Jouw naam:'
      input type: 'text'

      label 'Site wachtwoord:'
      input type: 'password'
    div '.modal-footer', ->
      button '.btn.primary', -> 'Inloggen'
