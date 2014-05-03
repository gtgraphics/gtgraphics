class @Editor.Control.AlignRight extends @Editor.Control.FontControl
  getCommand: ->
    'justifyright'

  getCaption: ->
    I18n.translate('javascript.editor.alignRight')

  getIcon: ->
    'align-right'

@Editor.Control.register('alignRight', @Editor.Control.AlignRight)