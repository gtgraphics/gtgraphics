class @Editor.Controls.Indent extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'indent'
    super

@Editor.Controls.register('indent', @Editor.Controls.Indent)