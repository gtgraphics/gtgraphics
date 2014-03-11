class @Editor.Controls.Underline extends @Editor.Controls.FontControl
  getCommand: ->
    'underline'

  getCaption: ->
    I18n.translate('editor.underline')

  getIcon: ->
    'underline'

@Editor.Controls.register('underline', @Editor.Controls.Underline)