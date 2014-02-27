class @Editor.Controls.Save extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = @icon = @command = 'save'
    super

@Editor.Controls.register('save', @Editor.Controls.Save)