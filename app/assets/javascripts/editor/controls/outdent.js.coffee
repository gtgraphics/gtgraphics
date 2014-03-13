class @Editor.Controls.Outdent extends @Editor.Controls.FontControl
  getCommand: ->
    'outdent'

  getCaption: ->
    I18n.translate('editor.outdent')

  getIcon: ->
    'outdent'

@Editor.Controls.register('outdent', @Editor.Controls.Outdent)