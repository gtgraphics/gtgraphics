class @Editor.Control.Unlink extends @Editor.Control.ButtonControl
  getCaption: ->
    I18n.translate('editor.unlink')

  getIcon: ->
    'unlink'

@Editor.Control.register('unlink', @Editor.Control.Unlink)