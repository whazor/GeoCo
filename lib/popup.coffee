module.exports = class
  constructor: (@popup, @tip='horizontal', @offset='') ->
    @popup.addClass 'popover'
    @popup.css zIndex: 10001
    @html = @popup.html()
    @popup.html ''
    @popup.append $('<div class="arrow" />')
    @inner = $('<div class="inner" />')
    @popup.append @inner
    @.close()
    @.redraw()

  redraw: ->
    @inner.html @html
    $('.cancel', @popup).bind 'click', (event) =>
      event.preventDefault()
      @.close()

  position: ->
    return unless @popup.is ":visible"
    console.log @tip
    switch @tip
      when 'horizontal'
        @popup.position
          of: $ @object
          my: 'left center'
          at: 'right center'
          offset: @offset
          collision: 'flip flip'
        is_flipped = @popup.hasClass 'ui-flipped-left'
        @popup.toggleClass 'left', is_flipped
        @popup.toggleClass 'right', !is_flipped
      when 'vertical'
        @popup.position
          of: $ @object
          my: 'center bottom'
          at: 'center bottom'
          offset: @offset
          collision: 'flip flip'
        is_flipped = @popup.hasClass 'ui-flipped-bottom'
        @popup.toggleClass 'above', !is_flipped
        @popup.toggleClass 'below', is_flipped

  show: (@object, dataFunc) ->
    @.redraw()
    @popup.show()
    @.position()
    dataFunc @popup

  close: -> @popup.hide()


