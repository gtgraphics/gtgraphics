class @Editor.Controls.Italic extends @Editor.Controls.FontControl
  getCommand: ->
    'italic'

  getCaption: ->
    I18n.translate('editor.italic')

  getIcon: ->
    'italic'

@Editor.Controls.register('italic', @Editor.Controls.Italic)