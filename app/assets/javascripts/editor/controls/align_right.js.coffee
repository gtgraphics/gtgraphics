class @Editor.Controls.AlignRight extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'align_right'
    @icon = 'align-right'
    @command = 'justifyright'
    super

@Editor.Controls.register('align_right', @Editor.Controls.AlignRight)