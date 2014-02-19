class @Editor.Controls.AlignCenter extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'alignCenter'
    @icon = 'align-center'
    @command = 'justifycenter'
    super

@Editor.Controls.register('alignCenter', @Editor.Controls.AlignCenter)