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
    @setUnchanged()

  # Element Constructors

  createControls: ->
    toolbar = new Editor.Toolbar(@)
    toolbar.render()

  destroy: ->
    console.warn 'not fully implemented'
    @region.removeClass('editable-region')
    @region.removeAttr('contenteditable')
    # TODO Destroy Container etc.

  applyEvents: ->
    # alias focus
    @element.focus (event) =>
      event.preventDefault()
      @region.focus().triggerHandler('focus')

    @region.click =>
      @region.triggerHandler('focus')

    @region.focus =>
      @onOpen()

    @region.find('*').focus =>
      @onOpen()

    @region.blur =>
      @element.blur()
      @onClose()

    @region.on 'textchange', =>
      @setChanged()
      true

    @element.on 'textchange', =>
      @changed = true
      @region.addClass('changed')
      @region.html(@element.val())
      true

    # Prevent links from being followed in editor mode
    @region.on 'click', 'a', (event) =>
      event.preventDefault() if @viewMode == 'editor'

  # Callbacks

  onInit: ->
    # @region and @element should be set at this point
    @element.addClass('editor-html')

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
    @element.val(@getHtml())

  setUnchanged: ->
    @changed = false
    @region.removeClass('changed')

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

  # View Mode Control

  changeViewMode: (viewMode, focus = false) ->
    previousViewMode = @viewMode
    @viewMode = viewMode
    switch @viewMode
      when 'editor'
        @element.hide()
        @region.show()
        if @disabled
          @region.addClass('disabled')
        else
          @enable(false)
        @region.focus().triggerHandler('focus') if focus
      when 'preview'
        @removeSelection()
        @element.hide()
        @region.show()
        @disable(false)
        @region.removeClass('disabled')
        @region.focus().triggerHandler('focus') if focus
      when 'html'
        @region.hide()
        @element.show()
        @enable(false) unless @disabled
        @element.focus().triggerHandler('focus') if focus
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