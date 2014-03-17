class @Editor.Control.Strikethrough extends @Editor.Control.FontControl
  getCommand: ->
    'strikethrough'

  getCaption: ->
    I18n.translate('editor.strikethrough')

  getIcon: ->
    'strikethrough'

@Editor.Control.register('strikethrough', @Editor.Control.Strikethrough)