class @Editor.Controls.Bold extends @Editor.Controls.FontControl
  getCommand: ->
    'bold'

  getCaption: ->
    I18n.translate('editor.bold')

  getIcon: ->
    'bold'

@Editor.Controls.register('bold', @Editor.Controls.Bold)