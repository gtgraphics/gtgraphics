class @Editor.Controls.Outdent extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = @command = 'outdent'
    super

@Editor.Controls.register('outdent', @Editor.Controls.Outdent)