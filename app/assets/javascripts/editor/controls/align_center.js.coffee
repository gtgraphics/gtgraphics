class @Editor.Controls.AlignCenter extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'align_center'
    @icon = 'align-center'
    @command = 'justifycenter'
    super

@Editor.Controls.register('align_center', @Editor.Controls.AlignCenter)