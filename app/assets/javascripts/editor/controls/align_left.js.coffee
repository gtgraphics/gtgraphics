class @Editor.Control.AlignLeft extends @Editor.Control.FontControl
  getCommand: ->
    'justifyleft'

  getCaption: ->
    I18n.translate('javascript.editor.align_left')

  getIcon: ->
    'align-left'

@Editor.Control.register('alignLeft', @Editor.Control.AlignLeft)