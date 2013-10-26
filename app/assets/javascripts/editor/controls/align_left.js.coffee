class @Editor.Controls.AlignLeft extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'align_left'
    @icon = 'align-left'
    @command = 'justifyleft'
    super

@Editor.Controls.register('align_left', @Editor.Controls.AlignLeft)