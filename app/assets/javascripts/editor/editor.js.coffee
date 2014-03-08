# An Editor is for a single Region

class @Editor
  @defaults = {
    viewMode: 'editor',
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
      ['orderedList', 'unorderedList', 'indent', 'outdent'],
      #['link', 'unlink'],
      #'image',
      'viewMode'
    ]
  }

  constructor: ($element, options = {}) ->
    @element = $element
    @options = jQuery.extend({}, Editor.defaults, options)

    @onInit()
    @changeViewMode(@options.viewMode, false)
    @applyEvents()

    @element.trigger('init.editor')

  # Getters

  getToolbar: ->
    console.warn 'No toolbar found'

  getRegion: ->
    console.warn 'No region found'

  destroy: ->
    console.warn 'No destroy action defined'

  applyEvents: ->
    # alias focus
    region = getRegion()

    @element.focus (event) =>
      event.preventDefault()
      @region.focus().triggerHandler('focus')

    @element.on 'textchange', =>
      @changed = true
      if region
        region.addClass('changed')
        region.html(@element.val())
      true

    region = getRegion()
    if region
      region
        .click =>
          region.triggerHandler('focus')
        .focus =>
          @onOpen()
        .blur =>
          @element.blur()
          @onClose()      
        .on 'click', 'a', (event) =>
          # Prevent links from being followed in editor mode
          event.preventDefault() if @viewMode == 'editor'
      region.find('*').focus =>
        @onOpen()

  # Callbacks

  onInit: ->

  onOpen: ->
    region = getRegion()
    region.addClass('editing') if region
    @element.trigger('open.editor')

  onClose: ->
    region = getRegion()
    region.removeClass('editing') if region
    @element.trigger('close.editor')

  # Enabling/Disabling

  enable: (updateState = true) ->
    @disabled = false if updateState
    @region.removeClass('disabled')
    @region.attr('contenteditable', true)
    @element.prop('disabled', false)

  disable: (updateState = true) ->
    @disabled = true if updateState
    @region.addClass('disabled')
    @region.removeAttr('contenteditable')
    @element.prop('disabled', true)


Editor.controls = {}