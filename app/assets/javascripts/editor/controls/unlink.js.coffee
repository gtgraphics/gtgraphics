class @Editor.Control.Unlink extends @Editor.Control.FontControl
  getCommand: ->
    'unlink'

  getCaption: ->
    I18n.translate('editor.unlink')

  getIcon: ->
    'unlink'

@Editor.Control.register('unlink', @Editor.Control.Unlink)