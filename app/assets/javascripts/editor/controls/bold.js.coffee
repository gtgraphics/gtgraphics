class @Editor.Controls.Bold extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'bold'
    super

@Editor.Controls.register('bold', @Editor.Controls.Bold)