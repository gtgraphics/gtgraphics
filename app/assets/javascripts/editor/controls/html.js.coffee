class @Editor.Control.Html extends @Editor.Control.ButtonControl
  executeCommandSync: ->
    alert 'Hello!'

  getCaption: ->
    I18n.translate('javascript.editor.viewModes.html')

  getIcon: ->
    'code'

@Editor.Control.register('html', @Editor.Control.Html)