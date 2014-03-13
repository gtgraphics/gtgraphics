class @Editor.Controls.AlignJustify extends @Editor.Controls.FontControl
  getCommand: ->
    'justifyfull'

  getCaption: ->
    I18n.translate('editor.alignJustify')

  getIcon: ->
    'align-justify'

@Editor.Controls.register('alignJustify', @Editor.Controls.AlignJustify)