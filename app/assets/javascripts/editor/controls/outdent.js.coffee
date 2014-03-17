class @Editor.Control.Outdent extends @Editor.Control.FontControl
  getCommand: ->
    'outdent'

  getCaption: ->
    I18n.translate('editor.outdent')

  getIcon: ->
    'outdent'

@Editor.Control.register('outdent', @Editor.Control.Outdent)