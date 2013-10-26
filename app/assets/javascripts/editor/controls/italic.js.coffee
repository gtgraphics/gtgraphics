class @Editor.Controls.Italic extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'italic'
    super

@Editor.Controls.register('italic', @Editor.Controls.Italic)