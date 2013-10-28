class @Editor.Controls.Unlink extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'unlink'
    super

@Editor.Controls.register('unlink', @Editor.Controls.Unlink)