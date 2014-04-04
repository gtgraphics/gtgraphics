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

  onInitEditor: (editor) ->
    control = @
    editor.$region.on 'dblclick', 'img', (event) ->
      $image = $(@)
      if editor.options.viewMode == 'richText'
        event.preventDefault()
        params = {}
        params.url = $image.attr('src')
        params.width = $image.attr('width')
        params.height = $image.attr('height')
        params.alternative_text = $image.attr('alt')
        params.alignment = $image.attr('align')
        params.external = !$image.data('imageId')
        _($image.data()).each (value, key) ->
          params[_(key).underscored()] = value
        control.perform(element: $image, params: params)

@Editor.Control.register('image', @Editor.Control.Image)