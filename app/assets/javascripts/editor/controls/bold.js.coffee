class @Editor.Control.Bold extends @Editor.Control.FontControl
  getCommand: ->
    'bold'

  getCaption: ->
    I18n.translate('javascript.editor.bold')

  getIcon: ->
    'bold'

@Editor.Control.register('bold', @Editor.Control.Bold)