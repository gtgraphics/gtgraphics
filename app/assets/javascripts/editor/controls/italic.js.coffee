class @Editor.Control.Italic extends @Editor.Control.FontControl
  getCommand: ->
    'italic'

  getCaption: ->
    I18n.translate('javascript.editor.italic')

  getIcon: ->
    'italic'

@Editor.Control.register('italic', @Editor.Control.Italic)