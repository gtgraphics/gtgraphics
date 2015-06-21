class @Editor.Control.Indent extends @Editor.Control.FontControl
  getCommand: ->
    'indent'

  getCaption: ->
    I18n.translate('javascript.editor.indent')

  getIcon: ->
    'indent'

@Editor.Control.register('indent', @Editor.Control.Indent)