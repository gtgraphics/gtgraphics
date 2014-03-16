class @Editor.Controls.Html extends @Editor.Controls.ButtonControl
  executeCommandSync: ->
    alert 'Hello!'

  getCaption: ->
    I18n.translate('editor.viewModes.html')

  getIcon: ->
    'code'

@Editor.Controls.register('html', @Editor.Controls.Html)