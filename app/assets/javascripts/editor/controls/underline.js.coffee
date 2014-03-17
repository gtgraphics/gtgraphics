class @Editor.Control.Underline extends @Editor.Control.FontControl
  getCommand: ->
    'underline'

  getCaption: ->
    I18n.translate('editor.underline')

  getIcon: ->
    'underline'

@Editor.Control.register('underline', @Editor.Control.Underline)