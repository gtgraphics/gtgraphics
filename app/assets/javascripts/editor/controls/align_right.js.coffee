class @Editor.Controls.AlignRight extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'alignRight'
    @icon = 'align-right'
    @command = 'justifyright'
    super

@Editor.Controls.register('alignRight', @Editor.Controls.AlignRight)