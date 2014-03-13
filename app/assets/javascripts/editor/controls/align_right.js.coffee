class @Editor.Controls.AlignRight extends @Editor.Controls.FontControl
  getCommand: ->
    'justifyright'

  getCaption: ->
    I18n.translate('editor.alignRight')

  getIcon: ->
    'align-right'

@Editor.Controls.register('alignRight', @Editor.Controls.AlignRight)