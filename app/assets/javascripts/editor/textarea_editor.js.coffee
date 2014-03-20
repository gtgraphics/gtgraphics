class @TextareaEditor
  @defaults =
    viewMode: 'richText'

  # Refreshers

  constructor: ($textarea, options = {}) ->
    jQuery.error 'input must be a textarea' unless $textarea.is('textarea')
    @$textarea = $textarea.addClass('editor-html')

    @options = _(options).defaults(TextareaEditor.defaults)
    @options.controls ||= Editor.Toolbar.defaults.controls
    
    @toolbar = @options.toolbar || new Editor.Toolbar(@, controls: @options.controls)

    # Get or create toolbar of this Editor (this is only the toolbar class not the rendered one)

    @refreshInternalState()

  render: ->
    unless @isRendered()
      inputId = @$textarea.attr('id')

      # First render region
      @$region = $('<div />', class: 'editor-region', contenteditable: true, designmode: 'on')
      @$region.attr('data-target', "##{inputId}") if inputId
      @$region.html(@$textarea.val())

      # Then a toolbar can be appended to the region
      @$toolbar = @toolbar.render()
      $toolbarWrapper = $('<div />', class: 'editor-controls').append(@$toolbar)

      # Finally, wrap all elements with a container
      @$editor = $('<div />', class: 'editor-container')
      @$editor.insertAfter(@$textarea)

      # Preserve original input as HTML container
      @$editor.append($toolbarWrapper)
      @$editor.append(@$region)
      @$editor.append(@$textarea)

      # Define events on newly created elements
      @applyEvents()

    @refreshInputState()
    @refreshControlStates() 
    @updateViewModeState(@options.viewMode)

    @$editor

  applyEvents: ->
    # Textarea Events
    
    @$textarea.on 'textchange', =>
      @refreshRegionContent()
      @$editor.trigger('editor:change', @)
      
    @$textarea.on 'focus blur keyup paste', =>
      @refreshControlStates()

    @$textarea.focus =>
      @$editor.addClass('focus')
      @$editor.trigger('editor:open', @)

    @$textarea.blur =>
      @$editor.removeClass('focus')
      @$editor.trigger('editor:close', @)

    # Region Events

    @$region.on 'keyup paste', =>
      @refreshInputContent()
      @$editor.trigger('editor:change', @)

    @$region.on 'focus blur keyup paste', =>
      @refreshControlStates()

    @$region.focus =>
      @$editor.addClass('focus')
      @$editor.trigger('editor:open', @)

    @$region.blur =>
      @$editor.removeClass('focus')
      @$editor.trigger('editor:close', @)

    @$region.click =>
      @$region.triggerHandler('focus')
  
    @$region.on 'click', 'a[href]', (event) =>
      # prevent links in regions from being clicked in Rich Text view
      event.preventDefault() if @options.viewMode == 'richText'

    # Controls

    @$editor.on 'editor:command:executed', (event, control) =>
      if control instanceof Editor.Control.ButtonControl
        @refreshInputContent()
        @$region.focus().triggerHandler('focus') 

  isRendered: ->
    @$editor? and @$editor != undefined

  destroy: ->
    @$editor.remove() if @isRendered()
    @$editor = null
    @$region = null # Region DOM element should have been destroyed with the editor
    @$toolbar = null
    @toolbar = null # Do not delete the toolbar DOM elements
    true

  # Refreshers

  refresh: ->
    @refreshInternalState()
    if @isRendered()
      @refreshInputState()
      @refreshControlStates()
    true

  refreshInternalState: ->
    @disabled = @$textarea.prop('disabled')

  refreshInputState: ->
    @$editor.prop('disabled', @disabled)

  refreshControlStates: ->
    if @isRendered()
      _(@toolbar.controls).each (control) ->
        control.refresh()
      true
    else
      false

  refreshRegionContent: ->
    @$region.html(@$textarea.val())

  refreshInputContent: ->
    @$textarea.val(@$region.html())

  # Enable / Disable

  enable: ->
    @disabled = false
    @$textarea.prop('disabled', false)
    if @isRendered()
      @$region.removeClass('disabled')
      @$region.attr('contenteditable', true)
    @$textarea.trigger('editor:enabled', @)
    true

  disable: ->
    @disabled = true
    @$textarea.prop('disabled', true)
    if @isRendered()
      @$region.addClass('disabled')
      @$region.removeAttr('contenteditable')
    @$textarea.trigger('editor:disabled', @)
    true

  # View Mode

  changeViewMode: (viewMode) ->
    previousViewMode = @options.viewMode
    @options.viewMode = viewMode
    if @isRendered()
      @updateViewModeState(viewMode)
      switch viewMode 
        when 'richText' then @$textarea.focus()
        when 'html' then @$region.focus()
      @$editor.trigger('editor:change:view', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    if @isRendered()
      switch viewMode
        when 'richText'
          @$textarea.hide()
          @$region.show()
          @$region.attr('contenteditable', true)
          @$region.attr('designmode', 'on')
          @$region.height(@$textarea.height())
        when 'html'
          @$textarea.show()
          @$region.hide()
          @$textarea.height(@$region.height())
        when 'preview'
          # TODO Load Preview with Interpolations (Liquid)
          #@removeSelection()
          @$textarea.hide()
          @$region.show()
          @$region.removeAttr('contenteditable').removeAttr('designmode')
        else
          console.error "invalid view mode: #{viewMode}"
      true
    else
      false