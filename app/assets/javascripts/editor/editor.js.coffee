class @Editor
  DEFAULTS = {
    controls: ['bold', 'italic', 'underline']
  }

  constructor: ($originalInput, options = {}) ->
    @input = $originalInput.hide()
    @input.attr('tabindex', '-1')
    @input.data('editor', @)
    @options = $.extend({}, DEFAULTS, options)

    @createEditableRegion()
    @createContainer()

    @input.addClass('editor-html')

    # Events
    @applyEvents()

    # Change Management
    @setUnchanged()

  createContainer: ->
    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@input)
    @container.append(@createControls())
    @container.append(@input)
    @container.append(@element)

  createEditableRegion: ->
    inputId = @input.attr('id')
    @element = $('<div />', contenteditable: true, class: 'editor-region')
    @element.attr('data-target', "##{inputId}") if inputId
    @element.html(@input.val())
    @element.css(height: @input.outerHeight())

  createControls: ->
    @controls = []
    $controls = $('<div />', class: 'editor-controls btn-toolbar')
    $.each @options.controls, (index, key) =>
      controlClass = Editor.Controls.get(key)
      @controls.push(new controlClass(@, $controls)) if controlClass
    $controls

  destroy: ->
    console.warn 'not fully implemented'
    @element.removeClass('editable-region')
    @element.removeAttr('contenteditable')
    # TODO Destroy Container etc.

  onOpen: ->
    @element.addClass('editing')

  onClose: ->
    @element.removeClass('editing')

  applyEvents: ->
    # Change Label Behavior
    $("label[for='#{@input.attr('id')}']").click =>
      @element.focus().triggerHandler('focus')

    # original input
    @input.focus =>
      @element.focus()

    @input.blur =>
      @element.blur()

    # editable region
    @element.focus =>
      @onOpen()

    @element.blur =>
      @onClose()

    @element.on 'keyup paste', =>
      @setChanged()

    @input.on 'keyup paste', =>
      @changed = true
      @element.addClass('changed')
      @element.html(@input.val())

  setChanged: ->
    @changed = true
    @element.addClass('changed')
    @input.val(@element.html())

  setUnchanged: ->
    @changed = false
    @element.removeClass('changed')

Editor.controls = {}