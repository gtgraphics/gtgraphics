class @Editor
  DEFAULTS = {
    viewMode: 'editor',
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['align_left', 'align_center', 'align_right', 'align_justify'],
      ['ordered_list', 'unordered_list'],
      ['link', 'unlink'],
      'picture',
      'view_mode'
    ]
  }

  constructor: ($originalInput, options = {}) ->
    @options = jQuery.extend({}, DEFAULTS, options)

    @input = $originalInput.hide()
    @input.attr('tabindex', '-1').attr('spellcheck', false)

    @createEditableRegion()
    @createContainer()
    @changeViewMode(@options.viewMode, false)

    @input.data('editor', @)
    @input.addClass('editor-html')

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
    @region = $('<div />', contenteditable: true, designmode: 'on', class: 'editor-region')
    @region.attr('data-target', "##{inputId}") if inputId
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

    @input.focus (event) =>
      event.preventDefault()
      @region.focus().triggerHandler('focus')

    @region.focus =>
      @onOpen()

    @region.blur =>
      @input.blur()
      @onClose()

    @region.on 'keyup paste', =>
      @setChanged()
      true

    @input.on 'keyup paste', =>
      @changed = true
      @region.addClass('changed')
      @region.html(@input.val())
      true

    # Prevent links from being followed in editor mode
    @region.on 'click', 'a', (event) =>
      if @viewMode == 'editor'
        event.preventDefault()

  setChanged: ->
    @changed = true
    @region.addClass('changed')
    @input.val(@region.html())

  setUnchanged: ->
    @changed = false
    @region.removeClass('changed')

  changeViewMode: (viewMode, focus = false) ->
    @viewMode = viewMode
    switch @viewMode
      when 'editor'
        @input.hide()
        @region.show()
        if @disabled
          @region.addClass('disabled')
        else
          @enable(false)
        @region.focus().triggerHandler('focus') if focus
      when 'preview'
        @removeSelection()
        @input.hide()
        @region.show()
        @disable(false)
        @region.removeClass('disabled')
        @region.focus().triggerHandler('focus') if focus
      when 'html'
        @region.hide()
        @input.show()
        @enable(false) unless @disabled
        @input.focus().triggerHandler('focus') if focus
      else
        jQuery.error('invalid view mode: ' + viewMode)
    @input.trigger('viewModeChanged.editor')

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

  removeSelection: ->
    if window.getSelection
      if window.getSelection().empty # Chrome
        window.getSelection().empty()
      else if window.getSelection().removeAllRanges # Firefox
        window.getSelection().removeAllRanges()
    else if document.selection # IE?
      document.selection.empty()

  storeSelection: ->
    @storedSelection = @getSelection()

  restoreSelection: ->
    if @storedSelection
      @setSelection(@storedSelection)
      @storedSelection = null

  getSelectedNode: ->
    if window.getSelection
      selection = window.getSelection()
    else if document.selection
      selection = document.selection
    #console.log selection
    if selection and selection.anchorNode
      $(selection.anchorNode.parentNode)
    else
      $()

  getSelection: ->
    if window.getSelection
      selection = window.getSelection()
      return selection.getRangeAt(0) if selection.getRangeAt
    else if document.selection
      selection = document.selection
      return selection.createRange()
    null

  setSelection: (storedSelection) ->
    if window.getSelection
      selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(storedSelection)
    else if document.selection and storedSelection.select
      storedSelection.select()

  # http://stackoverflow.com/questions/6690752/insert-html-at-caret-in-a-contenteditable-div
  pasteHtml: (html) ->
    html = $(html) if html instanceof String
    html = html.get(0).outerHTML if html instanceof jQuery

    if window.getSelection
      # IE9 and non-IE
      sel = window.getSelection()
      if sel.getRangeAt and sel.rangeCount
        range = sel.getRangeAt(0)
        range.deleteContents()
        
        # Range.createContextualFragment() would be useful here but is
        # only relatively recently standardized and is not supported in
        # some browsers (IE9, for one)
        el = document.createElement("div")
        el.innerHTML = html
        frag = document.createDocumentFragment()
        node = undefined
        lastNode = undefined
        while (node = el.firstChild)
          lastNode = frag.appendChild(node) 
        range.insertNode(frag)
        
        # Preserve the selection
        if lastNode
          range = range.cloneRange()
          range.setStartAfter(lastNode)
          range.collapse true
          sel.removeAllRanges()
          sel.addRange(range)

        @region.trigger('paste')

    # IE < 9
    else if document.selection and document.selection.type isnt "Control"
      document.selection.createRange().pasteHTML(html)
      @region.trigger('paste')


Editor.controls = {}