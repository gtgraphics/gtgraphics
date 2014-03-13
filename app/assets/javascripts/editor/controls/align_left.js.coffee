class @Editor.Controls.AlignLeft extends @Editor.Controls.FontControl
  getCommand: ->
    'justifyleft'

  getCaption: ->
    I18n.translate('editor.alignLeft')

  getIcon: ->
    'align-left'

@Editor.Controls.register('alignLeft', @Editor.Controls.AlignLeft)