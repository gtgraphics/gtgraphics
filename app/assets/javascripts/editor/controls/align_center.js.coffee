class @Editor.Control.AlignCenter extends @Editor.Control.FontControl
  getCommand: ->
    'justifycenter'

  getCaption: ->
    I18n.translate('javascript.editor.alignCenter')

  getIcon: ->
    'align-center'

@Editor.Control.register('alignCenter', @Editor.Control.AlignCenter)