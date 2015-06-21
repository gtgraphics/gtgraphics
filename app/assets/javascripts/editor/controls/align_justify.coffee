class @Editor.Control.AlignJustify extends @Editor.Control.FontControl
  getCommand: ->
    'justifyfull'

  getCaption: ->
    I18n.translate('javascript.editor.align_justify')

  getIcon: ->
    'align-justify'

@Editor.Control.register('alignJustify', @Editor.Control.AlignJustify)