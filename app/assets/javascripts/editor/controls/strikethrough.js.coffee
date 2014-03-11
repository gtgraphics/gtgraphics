class @Editor.Controls.Strikethrough extends @Editor.Controls.FontControl
  getCommand: ->
    'strikethrough'

  getCaption: ->
    I18n.translate('editor.strikethrough')

  getIcon: ->
    'strikethrough'

@Editor.Controls.register('strikethrough', @Editor.Controls.Strikethrough)