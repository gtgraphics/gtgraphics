class @Editor.Control.Image extends @Editor.Control.DialogButtonControl
  ELEMENT_SELECTOR = 'img'

  getCaption: ->
    I18n.translate('editor.image')

  getDialogUrl: ->
    Editor.Control.Image.dialogUrl

  getIcon: ->
    'picture-o'

  queryEnabled: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandEnabled('insertimage', false, null)
    else
      false

  onInitEditor: (editor) ->
    control = @

    editor.$region.on 'dragend', ELEMENT_SELECTOR, (event) ->
      # refresh content if image has been moved
      editor.refreshInputContent()

    editor.$region.on 'click', ELEMENT_SELECTOR, (event) ->
      editor.setSelectionAroundNode(@)

    editor.$region.on 'dblclick', ELEMENT_SELECTOR, (event) ->
      event.stopPropagation()
      $image = $(@)
      if editor.options.viewMode == 'richText'
        event.preventDefault()
        control.perform(element: $image, params: control.extractContextParams(editor, $image))

  extractContextParams: (editor, $image) ->
    editorParams = {}
    if $image instanceof jQuery
      _(editorParams).extend
        url: $image.attr('src')
        width: $image.attr('width')
        height: $image.attr('height')
        alternative_text: $image.attr('alt')
        alignment: $image.attr('align')
        external: !$image.data('imageId')
      _($image.data()).each (value, key) ->
        editorParams[_(key).underscored()] = value
    { editor: editorParams }

  getElementFromSelection: ->
    editor = @getActiveEditor()
    $(editor.getSelectedRange().getNodes()).filter(ELEMENT_SELECTOR)

@Editor.Control.register('image', @Editor.Control.Image)