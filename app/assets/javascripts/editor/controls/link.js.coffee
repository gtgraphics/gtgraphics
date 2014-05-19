class @Editor.Control.Link extends @Editor.Control.DialogButtonControl
  ELEMENT_SELECTOR = 'a[href]'

  getCaption: ->
    I18n.translate('javascript.editor.link')

  getDialogUrl: ->
    Editor.Control.Link.dialogUrl

  getIcon: ->
    'link'

  queryEnabled: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandEnabled('createlink', false, null)
    else
      false

  queryActive: ->
    doc = @getRegionDocument()
    $element = @getElementFromSelection()
    ($element? and $element.any()) or (doc? and doc.queryCommandState('createlink'))

  onInitEditor: (editor) ->
    control = @

    editor.$region.on 'click', ELEMENT_SELECTOR, (event) ->
      editor.setSelectionAroundNode(@)
      $link = $(@)
      if editor.options.viewMode == 'richText'
        if event.ctrlKey
          url = $link.attr('href')
          target = $link.attr('target')
          if target == '_blank'
            window.open(url)
          else
            Turbolinks.visit(url)
        else
          event.preventDefault()
      true

    editor.$preview.on 'click', ELEMENT_SELECTOR, ->
      $link = $(@)
      if editor.options.viewMode == 'preview'
        url = $link.attr('href')
        target = $link.attr('target')
        if target == '_blank'
          window.open(url)
        else
          Turbolinks.visit(url)

    editor.$region.on 'dblclick', ELEMENT_SELECTOR, (event) ->
      event.stopPropagation()
      $link = $(@)
      if editor.options.viewMode == 'richText'
        event.preventDefault()
        control.perform(element: $link, params: control.extractContextParams(editor, $link))

  extractContextParams: (editor, link) ->
    editorParams = { content: @getSelectedHtml() }
    console.log editorParams
    if link instanceof jQuery
      $link = link
      pageId = $link.data('pageId')
      editorParams.external = true unless pageId
      editorParams.url = $link.attr('href')
      editorParams.target = $link.attr('target')
      _($link.data()).each (value, key) ->
        editorParams[_(key).underscored()] = value
    { editor: editorParams }

  getSelectedHtml: ->
    editor = @getActiveEditor()
    if editor
      $href = @getElementFromSelection()
      if $href.any()
        $href.html()
      else
        editor.getSelectedHtml()
    else
      null

  getElementFromSelection: ->
    editor = @getActiveEditor()
    if editor
      $nodes = editor.getSelectedNodes()
      $nodes.filter(ELEMENT_SELECTOR).add($nodes.closest(ELEMENT_SELECTOR))
    else
      jQuery()

@Editor.Control.register('link', @Editor.Control.Link)