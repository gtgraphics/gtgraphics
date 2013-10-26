class @Editor.Controls.Strikethrough extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'strikethrough'
    super

@Editor.Controls.register('strikethrough', @Editor.Controls.Strikethrough)