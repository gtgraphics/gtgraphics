class @Editor.Control.Link extends @Editor.Control.DialogButtonControl
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

@Editor.Control.register('link', @Editor.Control.Link)