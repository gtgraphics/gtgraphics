class @Editor.Controls.Underline extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'underline'
    super

@Editor.Controls.register('underline', @Editor.Controls.Underline)