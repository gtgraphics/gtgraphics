class @Editor
  DEFAULTS = {
    viewMode: 'editor',
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['align_left', 'align_center', 'align_right', 'align_justify'],
      ['ordered_list', 'unordered_list', 'indent', 'outdent'],
      ['link', 'unlink'],
      'image',
      'view_mode'
    ]
  }

  constructor: ($originalInput, options = {}) ->
    @options = jQuery.extend({}, DEFAULTS, options)

    @input = $originalInput.hide()
    @input.attr('spellcheck', false)

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


  # Element Constructors

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

  applyEvents: ->
    # Change Label Behavior
    $("label[for='#{@input.attr('id')}']").click =>
      @region.focus().triggerHandler('focus')

    @input.focus (event) =>
      event.preventDefault()
      @region.focus().triggerHandler('focus')

    @region.click =>
      @region.triggerHandler('focus')

    @region.focus =>
      @onOpen()

    @region.find('*').focus =>
      @onOpen()

    @region.blur =>
      @input.blur()
      @onClose()

    @region.on 'textchange', =>
      @setChanged()
      true

    @input.on 'textchange', =>
      @changed = true
      @region.addClass('changed')
      @region.html(@input.val())
      true

    # Prevent links from being followed in editor mode
    @region.on 'click', 'a', (event) =>
      event.preventDefault() if @viewMode == 'editor'


  # Callbacks

  onOpen: ->
    @region.addClass('editing')
    @container.addClass('focus')

  onClose: ->
    @region.removeClass('editing')
    @container.removeClass('focus')


  # Change Management

  setChanged: ->
    @changed = true
    @region.addClass('changed')
    @input.val(@getHtml())

  setUnchanged: ->
    @changed = false
    @region.removeClass('changed')


  # Enabling/Disabling

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


  # View Mode Control

  changeViewMode: (viewMode, focus = false) ->
    previousViewMode = @viewMode
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
        return jQuery.error('invalid view mode: ' + viewMode)
    @region.trigger('viewModeChanged.editor', viewMode, previousViewMode)
    #@setChanged()


  # Selection Handling

  removeSelection: ->
    @getSelection().removeAllRanges()

  storeSelection: ->
    @storedSelection = rangy.saveSelection()

  restoreSelection: ->
    if @storedSelection
      @setSelection(@storedSelection)
      @storedSelection = null

  getSelectedNode: ->
    $(getSelection().anchorNode)

  getSelectedNodeParent: ->
    $(getSelection().anchorNode.parentNode)

  getSelection: ->
    rangy.getSelection()

  setSelection: (storedSelection) ->
    range.restoreSelection(storedSelection)


  # HTML Input/Output

  getHtml: ->
    $regionClone = @region.clone()
    $elements = $regionClone.find('*')

    $elements.each ->
      # Remove data-editor-* attributes and elements with editor-element class
      $element = $(@)
      if $element.hasClass('editor-element')
        # removes all elements having class "editor-element"
        $element.remove()
      else
        # removes all data-editor* attributes
        jQuery.each @attributes, ->
          $element.removeAttr(@name) if @name.match(/^data-editor/)

    $elements.each ->
      $element = $(@)
      if $element.hasClass('editor-wrapper')
        $element.children().first().unwrap($element)

    $regionClone.html()

  # http://stackoverflow.com/questions/6690752/insert-html-at-caret-in-a-contenteditable-div
  pasteHtml: (html) ->
    # TODO Replace with rangy
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