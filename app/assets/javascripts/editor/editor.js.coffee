class @Editor
  @defaults =
    viewMode: 'richText'
    stylesheetFile: null

  # Refreshers

  constructor: ($textarea, options = {}) ->  
    jQuery.error 'input must be a textarea' unless $textarea.is('textarea')
    @$textarea = $textarea.addClass('editor-html')
    @$textarea.data('editor', @)

    @options = options
    @options = _(@options).defaults(Editor.defaults)
    @options = _(@options).defaults(_($textarea.data()).pick('previewUrl'))
    @options.controls ||= Editor.Toolbar.defaults.controls
    
    @toolbar = @options.toolbar || new Editor.Toolbar(@, controls: @options.controls)

    # Get or create toolbar of this Editor (this is only the toolbar class not the rendered one)

    @refreshInternalState()

  prepareRegionFrame: ($regionFrame) ->
    @$regionFrame = $regionFrame
    @$regionFrame.css(width: '100%')
    $base = $('<base />', target: '_parent')
    $stylesheet = $('<link />', href: @options.stylesheetFile, media: 'all', rel: 'stylesheet')
    @$regionFrame.contents().find('head').append($base).append($stylesheet)
    @$region = @$regionFrame.contents().find('body').attr('contenteditable', true)


  preparePreviewFrame: ($previewFrame) ->
    @$previewFrame = $previewFrame

    @$previewFrame.css(width: '100%')
    $base = $('<base />', target: '_parent')
    $stylesheet = $('<link />', href: @options.stylesheetFile, media: 'all', rel: 'stylesheet')
    @$previewFrame.contents().find('head').append($base).append($stylesheet)
    @$preview = @$previewFrame.contents().find('body')

  prepareFrames: ->
    # Copy HTML from textarea to region and preview containers
    @refreshRegionContent()

    # Define events on newly created elements
    @applyEvents()

    @refreshInputState()
    @refreshControlStates() 
    @updateViewModeState(@options.viewMode)

    # This is a hotfix to determine the textarea height in hidden wrapper elements
    interval = setInterval =>
      if @$textarea.outerHeight() > 0
        @refreshInputState()
        @refreshControlStates() 
        @updateViewModeState(@options.viewMode)
        clearInterval(interval)
    , 10

  render: ->
    if @isRendered()

      @refreshInputState()
      @refreshControlStates() 
      @updateViewModeState(@options.viewMode)
      @$editor.trigger('editor:rendered', @)

    else

      inputId = @$textarea.attr('id')

      # Create the toolbar
      @$toolbar = @toolbar.render()
      $toolbarWrapper = $('<div />', class: 'editor-controls').append(@$toolbar)

      # Create a container around all editor elements
      @$editor = $('<div />', class: 'editor-container')
      @$editor.insertAfter(@$textarea)

      # Preserve original input as HTML container
      @$editor.append($toolbarWrapper)

      # Move HTML text area with editor container
      @$editor.append(@$textarea)

      # Add iframe with editable body to avoid conflicts when injecting invalid HTML
      $regionFrame = $('<iframe />', 'data-target': "##{inputId}", class: 'editor-region', seamless: true).appendTo(@$editor)
      $previewFrame = $('<iframe />', 'data-target': "##{inputId}", class: 'editor-preview', seamless: true).appendTo(@$editor)

      @prepareRegionFrame($regionFrame)
      @preparePreviewFrame($previewFrame)
      @prepareFrames()

      # FF Fix
      $regionFrame.on 'load', => 
        @prepareRegionFrame($regionFrame)
        $previewFrame.on 'load', => 
          @preparePreviewFrame($previewFrame)
          @prepareFrames()

      @$editor.trigger('editor:created', @)
      @$editor.trigger('editor:rendered', @)

    @$editor

  applyEvents: ->
    # Textarea Events
    
    @$textarea.on 'textchange', =>
      @refreshRegionContent()
      @$editor.trigger('editor:change', @)
      
    @$textarea.on 'focus blur keyup paste', =>
      @refreshControlStates()

    @$textarea.click (event) =>
      if @options.viewMode == 'richText'
        event.preventDefault()
        @$region.focus().triggerHandler('focus')

    @$textarea.focus =>
      @onOpen()

    @$textarea.blur =>
      @onClose()

    # Region Events

    @$region.on 'keyup paste', =>
      @refreshInputContent()
      @$editor.trigger('editor:change', @)

    @$region.on 'focus blur keyup paste', =>
      @refreshControlStates()

    @$region.focus =>
      @onOpen() if @options.viewMode == 'richText'

    @$region.blur =>
      @onClose()

    @$region.click =>
      @$region.triggerHandler('focus')

    # Controls

    _(@toolbar.controls).each (control) =>
      control.onInitEditor(@)

    @$editor.on 'editor:command:executed', (event, control) =>
      if control instanceof Editor.Control.ButtonControl
        @refreshInputContent()
        @$region.focus().triggerHandler('focus') 

  isRendered: ->
    @$editor? and @$editor != undefined

  destroy: ->
    @$editor.remove() if @isRendered()
    @$editor = null
    @$regionFrame = null
    @$region = null # Region DOM element should have been destroyed with the editor
    @$previewFrame = null
    @$preview = null
    @$toolbar = null
    @toolbar = null # Do not delete the toolbar DOM elements
    true

  # Hooks

  onOpen: ->
    @toolbar.activeEditor = @
    if @isRendered()
      @$editor.addClass('focus')
      @$editor.trigger('editor:open', @)

  onClose: ->
    if @isRendered()
      @$editor.removeClass('focus')
      @$editor.trigger('editor:close', @)

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
      @$editor.removeClass('disabled')
      @$region.attr('contenteditable', true)
    @$textarea.trigger('editor:enabled', @)
    true

  disable: ->
    @disabled = true
    @$textarea.prop('disabled', true)
    if @isRendered()
      @$editor.addClass('disabled')
      @$region.removeAttr('contenteditable')
    @$textarea.trigger('editor:disabled', @)
    true

  # View Mode

  changeViewMode: (viewMode) ->
    previousViewMode = @options.viewMode
    @options.viewMode = viewMode
    if @isRendered()
      @updateViewModeState(viewMode)
      # TODO FF Fix
      switch viewMode 
        when 'richText' then @$region.focus().triggerHandler('focus')
        when 'html' then @$textarea.focus().triggerHandler('focus')
      @refreshControlStates()
      @$editor.trigger('editor:change:view', viewMode, previousViewMode)

  updateViewModeState: (viewMode) ->
    if @isRendered()
      switch viewMode
        when 'richText'
          @$regionFrame.show().outerHeight(@$textarea.outerHeight())
          @$textarea.hide()
          @$previewFrame.hide()
        when 'html'
          @$regionFrame.hide()
          @$textarea.show().outerHeight(@$regionFrame.outerHeight())
          @$previewFrame.hide()
        when 'preview'
          # TODO Load Preview with Interpolations (Liquid)
          @$regionFrame.hide()
          @$textarea.hide()
          @$previewFrame.show().outerHeight(@$regionFrame.outerHeight())

          # First load a preview captured from HTML content of the textarea,
          # then load a proper preview (with interpolations) from a specified URL
          html = @$textarea.val()
          @$preview.html(html)
          if @options.previewUrl
            jQuery.get @options.previewUrl, { html: html }, (html) =>
              @$preview.html(html)
        else
          console.error "invalid view mode: #{viewMode}"
      true
    else
      false

  # Selection

  getSelection: ->
    jQuery.error 'editor has not been rendered' unless @isRendered()
    rangy.getIframeSelection(@$regionFrame.get(0))

  getSelectedRange: ->
    @getSelection().getRangeAt(0)

  getSelectedNodes: ->
    $(@getSelectedRange().getNodes())

  deleteSelectedContent: ->
    range = @getSelectedRange()
    range.deleteContents()

  getSelectedText: ->
    @getSelectedRange().toString()

  getSelectedHtml: ->
    @getSelectedRange().toHtml()

  insertText: (text) ->
    @insertNode(document.createTextNode(text))

  insertHtml: (html) ->
    html = html.html() if html instanceof jQuery
    range = @getSelectedRange()
    @insertNode(range.createContextualFragment(html))

  insertNode: (node) ->
    node = node.get(0) if node instanceof jQuery
    selection = @getSelection()
    range = @getSelectedRange()
    range.deleteContents()
    firstChild = node.firstChild
    lastChild = node.lastChild
    range.insertNode(node)
    @setSelectionAroundNodes(firstChild, lastChild)
    @refreshInputContent()
    @$textarea.trigger('editor:inserted', @, node)

  setSelectionAroundNode: (node) ->
    @setSelectionAroundNodes(node, node)

  setSelectionAroundNodes: (startNode, endNode) ->
    startNode = startNode.get(0) if startNode instanceof jQuery
    endNode = endNode.get(0) if endNode instanceof jQuery
    range = rangy.createRange()
    range.setStartBefore(startNode)
    range.setEndAfter(endNode)
    selection = @getSelection()
    selection.setSingleRange(range)