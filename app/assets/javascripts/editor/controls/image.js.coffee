class @Editor.Control.Image extends @Editor.Control.DialogButtonControl
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


@Editor.Control.register('image', @Editor.Control.Image)