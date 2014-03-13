class @Editor.Controls.Indent extends @Editor.Controls.FontControl
  getCommand: ->
    'indent'

  getCaption: ->
    I18n.translate('editor.indent')

  getIcon: ->
    'indent'

@Editor.Controls.register('indent', @Editor.Controls.Indent)