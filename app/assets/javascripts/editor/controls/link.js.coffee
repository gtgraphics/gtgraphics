class @Editor.Control.Link extends @Editor.Control.DialogButtonControl
  ELEMENT_SELECTOR = 'a[href]'

  getCaption: ->
    I18n.translate('editor.link')

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

  extractContextParams: (editor, $link) ->
    editorParams = { content: editor.getSelectedHtml() }
    if $link instanceof jQuery
      # only if an anchor tag is selected
      editorParams.href = $link.attr('href')
      editorParams.target = $link.attr('target')
      _($link.data()).each (value, key) ->
        editorParams[_(key).underscored()] = value
    { editor: editorParams }

  getElementFromSelection: ->
    range = @getActiveEditor().getSelectedRange()
    # $(range.commonAncestorContainer).closest(ELEMENT_SELECTOR)
    $(range.getNodes()).filter(ELEMENT_SELECTOR)

@Editor.Control.register('link', @Editor.Control.Link)