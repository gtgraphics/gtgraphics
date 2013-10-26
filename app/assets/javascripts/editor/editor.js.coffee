class @Editor
  DEFAULTS = {
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['align_left', 'align_center', 'align_right', 'align_justify'],
      ['ordered_list', 'unordered_list'],
      'link',
      'html'
    ]
  }

  constructor: ($originalInput, options = {}) ->
    @input = $originalInput.hide()
    @input.attr('tabindex', '-1')
    @input.data('editor', @)
    @options = jQuery.extend({}, DEFAULTS, options)

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
    #@element.css(height: @input.outerHeight())

  createControls: ->
    @controls = []
    $controls = $('<div />', class: 'editor-controls btn-toolbar')

    @options.controls.forEach (keyOrGroup) =>
      if jQuery.isArray(keyOrGroup)
        $toolbar = $('<div />', class: 'btn-group')
        keyOrGroup.forEach (key) =>
          controlClass = Editor.Controls.get(key)
          if controlClass
            control = new controlClass(@, $toolbar)
            @controls.push(control)
          else
            console.warn "Control not found: #{key}"
        $toolbar.appendTo($controls)
      else
        controlClass = Editor.Controls.get(keyOrGroup)
        if controlClass
          control = new controlClass(@, $controls)
          @controls.push(control)
        else
          console.warn "Control not found: #{keyOrGroup}"

    $controls

  destroy: ->
    console.warn 'not fully implemented'
    @element.removeClass('editable-region')
    @element.removeAttr('contenteditable')
    # TODO Destroy Container etc.

  onOpen: ->
    @element.addClass('editing')
    @container.addClass('focus')

  onClose: ->
    @element.removeClass('editing')
    @container.removeClass('focus')

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
      true

    @input.on 'keyup paste', =>
      @changed = true
      @element.addClass('changed')
      @element.html(@input.val())
      true

  setChanged: ->
    @changed = true
    @element.addClass('changed')
    @input.val(@element.html())

  setUnchanged: ->
    @changed = false
    @element.removeClass('changed')

Editor.controls = {}