class @Editor.Controls.AlignLeft extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'alignLeft'
    @icon = 'align-left'
    @command = 'justifyleft'
    super

@Editor.Controls.register('alignLeft', @Editor.Controls.AlignLeft)