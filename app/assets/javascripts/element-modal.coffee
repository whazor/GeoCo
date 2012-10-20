### =========================================================
* bootstrap-elementModal.js v2.1.1
* http:#twitter.github.com/bootstrap/javascript.html#elementModals
* =========================================================
* Copyright 2012 Twitter, Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use @ file except in compliance with the License.
* You may obtain a copy of the License at
*
* http:#www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
* ========================================================= ###


### MODAL CLASS DEFINITION
* ====================== ###

class ElementModal
  constructor: (element, @options) ->
    @$element = $(element)
    .on 'click.dismiss.elementModal', '[data-dismiss="elementModal"]', $proxy @hide, @
    @$element.find('.elementModal-body').load @options.remote if @options.remove?

  toggle: =>
    @[!@isShown ? 'show' : 'hide']()

  show: =>
    e = $.Event('show')

    @$element.trigger(e)

    return if @isShown || e.isDefaultPrevented()

    $('body').addClass('elementModal-open')

    @isShown = true

    @escape()

    @backdrop =>
      transition = $.support.transition && that.$element.hasClass('fade')

      if !@$element.parent().length
        @$element.appendTo(document.body) #don't move elementModals dom position

      @$element
      .show()

      @$element[0].offsetWidth # force reflow if transition

      @$element
      .addClass 'in'
      .attr('aria-hidden', false)
      .focus()

      @enforceFocus()

      if transition?
        @$element.one $.support.transition.end, -> @$element.trigger('shown')
      else
        @$element.trigger('shown')

  hide: (e) =>
    e?.preventDefault()

    e = $.Event('hide')

    @$element.trigger e

    return if !@isShown || e.isDefaultPrevented()

    @isShown = false

    $('body').removeClass('elementModal-open')

    @escape()

    $(document).off('focusin.elementModal')

    @$element
    .removeClass('in')
    .attr('aria-hidden', true)

    if $.support.transition && @$element.hasClass('fade')
      @hideWithTransition()
    else
      @hideElementModal()

  enforceFocus: =>
    $(document).on 'focusin.elementModal', (e) =>
      if @$element[0] isnt e.target && not @$element.has(e.target).length
        @$element.focus()

  escape: =>
    if @isShown && @options.keyboard
      @$element.on 'keyup.dismiss.elementModal', (e) =>
        e.which == 27 && @hide()
    else if !@isShown
      @$element.off 'keyup.dismiss.elementModal'

  hideWithTransition: =>
    timeout = setTimeout (=>
      that.$element.off($.support.transition.end)
      that.hideElementModal()
    ), 500

    @$element.one $.support.transition.end, =>
      clearTimeout timeout
      @hideElementModal()

  hideElementModal: (that) =>
    @$element
    .hide()
    .trigger('hidden')

    @backdrop()

  removeBackdrop: =>
    @$backdrop.remove()
    @$backdrop = null

  backdrop: (callback) =>
    animate = @$element.hasClass('fade') ? 'fade' : ''

    if @isShown && @options.backdrop
      doAnimate = $.support.transition && animate

      @$backdrop = $('<div class="elementModal-backdrop ' + animate + '" />')
      .appendTo(document.body)

      if @options.backdrop isnt 'static'
        @$backdrop.click @hide

      @$backdrop[0].offsetWidth if doAnimate # force reflow

      @$backdrop.addClass('in')

      if doAnimate
        @$backdrop.one($.support.transition.end, callback)
      else
        callback()

    else if !@isShown && @$backdrop
      @$backdrop.removeClass('in')

      if $.support.transition && @$element.hasClass('fade')
        @$backdrop.one($.support.transition.end, $.proxy(@removeBackdrop, @))
      else
        @removeBackdrop()

    else if callback?
      callback()


### MODAL PLUGIN DEFINITION
* ======================= ###

$.fn.elementModal = (option) ->
  @each ->
    $this = $(@)
    data = $this.data 'elementModal'
    options = $.extend {}, $.fn.elementModal.defaults, $this.data(), typeof option == 'object' && option
    $this.data('elementModal', (data = new ElementModal(@, options))) if !data
    if typeof option == 'string'
      data[option]()
    else if options.show
      data.show()


$.fn.elementModal.defaults =
  backdrop: true
  keyboard: true
  show: true

$.fn.elementModal.Constructor = ElementModal


### MODAL DATA-API
* ============== ###

$ ->
  $('body').on 'click.elementModal.data-api', '[data-toggle="elementModal"]', (e) ->
    $this = $(@)
    href = $this.attr('href')
    $target = $($this.attr('data-target') || (href && href.replace(/.*(?=#[^\s]+$)/, ''))) #strip for ie7
    option = if $target.data('elementModal') then 'toggle' else $.extend({ remote: !/#/.test(href) && href }, $target.data(), $this.data())

    e.preventDefault()

    $target
    .elementModal(option)
    .one 'hide', ->
      $this.focus()