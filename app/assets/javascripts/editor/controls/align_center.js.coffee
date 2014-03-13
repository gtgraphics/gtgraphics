class @Editor.Controls.AlignCenter extends @Editor.Controls.FontControl
  getCommand: ->
    'justifycenter'

  getCaption: ->
    I18n.translate('editor.alignCenter')

  getIcon: ->
    'align-center'

@Editor.Controls.register('alignCenter', @Editor.Controls.AlignCenter)