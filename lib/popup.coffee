module.exports = class
  constructor: (@popup) ->
    @popup.addClass 'popover left'
    @popup.css zIndex: 10001
    @html = @popup.html()
    @popup.html ''
    @popup.append $('<div class="arrow" />')
    @inner = $('<div class="inner" />').html @html
    @popup.append @inner
    @.close()
    $('.cancel', @popup).bind 'click', (event) =>
      event.preventDefault()
      @.close()

  position: ->
    @popup.position
      of: $ @object
      my: 'left center'
      at: 'right center'
      offset: ''
      collision: 'flip flip'
    is_flipped = @popup.hasClass 'ui-flipped-left'
    @popup.toggleClass 'left', is_flipped
    @popup.toggleClass 'right', !is_flipped

  show: (@object, dataFunc) ->
    @inner.html @html
    @popup.show()
    @.position()
    dataFunc @popup
  close: -> @popup.hide()


