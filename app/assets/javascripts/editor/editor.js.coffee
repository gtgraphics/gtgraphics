class @Editor
  DEFAULTS = {
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['align_left', 'align_center', 'align_right', 'align_justify'],
      ['ordered_list', 'unordered_list'],
      'link',
      'view_mode'
    ]
  }

  constructor: ($originalInput, options = {}) ->
    @viewMode = 'editor'

    @input = $originalInput.hide()
    @input.attr('tabindex', '-1').attr('spellcheck', false)
    @input.data('editor', @)
    @input.addClass('editor-html')
    @options = jQuery.extend({}, DEFAULTS, options)

    @createEditableRegion()
    @createContainer()

    # Determine Disabled/Enabled State
    if @input.prop('disabled')
      @disable()
    else
      @enable()

    # Events
    @applyEvents()

    # Change Management
    @setUnchanged()

  createContainer: ->
    @container = $('<div />', class: 'editor-container')
    @container.insertAfter(@input)
    @container.append(@createControls())
    @container.append(@input)
    @container.append(@region)

  createEditableRegion: ->
    inputId = @input.attr('id')
    @region = $('<div />', contenteditable: true, class: 'editor-region')
    @region.attr('data-target', "##{inputId}") if inputId
    @region.outerHeight(@input.outerHeight(true))
    @region.html(@input.val())
    @region.attr('spellcheck', false)

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
    @region.removeClass('editable-region')
    @region.removeAttr('contenteditable')
    # TODO Destroy Container etc.

  onOpen: ->
    @region.addClass('editing')
    @container.addClass('focus')

  onClose: ->
    @region.removeClass('editing')
    @container.removeClass('focus')

  applyEvents: ->
    # Change Label Behavior
    $("label[for='#{@input.attr('id')}']").click =>
      @region.focus().triggerHandler('focus')

    # original input
    @input.focus =>
      @region.focus()

    @input.blur =>
      @region.blur()

    # editable region
    @region.focus =>
      @onOpen()

    @region.blur =>
      @onClose()

    @region.on 'keyup paste', =>
      @setChanged()
      true

    @input.on 'keyup paste', =>
      @changed = true
      @region.addClass('changed')
      @region.html(@input.val())
      true

  setChanged: ->
    @changed = true
    @region.addClass('changed')
    @input.val(@region.html())

  setUnchanged: ->
    @changed = false
    @region.removeClass('changed')

  changeViewMode: (viewMode, focus = false) ->
    if @viewMode == viewMode
      if focus
        switch @viewMode
          when 'editor', 'preview'
            @region.focus()
          when 'html'
            @input.focus()
          else
            jQuery.error('invalid view mode: ' + viewMode)
    else
      switch viewMode
        when 'editor'
          @input.hide()
          @region.show()
          @region.outerHeight(@input.outerHeight(true))
          if @disabled
            @region.addClass('disabled')
          else
            @enable(false)
          @region.focus().triggerHandler('focus') if focus
        when 'preview'
          @removeSelection()
          @input.hide()
          @region.show()
          @region.outerHeight(@input.outerHeight(true))
          @disable(false)
          @region.removeClass('disabled')
          @region.focus().triggerHandler('focus') if focus
        when 'html'
          @region.hide()
          @input.show()
          @input.outerHeight(@region.outerHeight(true))
          @enable(false) unless @disabled
          @input.focus().triggerHandler('focus') if focus
        else
          jQuery.error('invalid view mode: ' + viewMode)
      @viewMode = viewMode

  removeSelection: ->
    if window.getSelection
      if window.getSelection().empty # Chrome
        window.getSelection().empty()
      else if window.getSelection().removeAllRanges # Firefox
        window.getSelection().removeAllRanges()
      else if document.selection # IE?
        document.selection.empty()

  enable: (updateState = true) ->
    @disabled = false if updateState
    @region.removeClass('disabled')
    @region.attr('contenteditable', true)
    @input.prop('disabled', false)

  disable: (updateState = true) ->
    @disabled = true if updateState
    @region.addClass('disabled')
    @region.removeAttr('contenteditable')
    @input.prop('disabled', true)



Editor.controls = {}