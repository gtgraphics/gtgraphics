class @Editor.Control.AlignRight extends @Editor.Control.FontControl
  getCommand: ->
    'justifyright'

  getCaption: ->
    I18n.translate('javascript.editor.align_right')

  getIcon: ->
    'align-right'

@Editor.Control.register('alignRight', @Editor.Control.AlignRight)