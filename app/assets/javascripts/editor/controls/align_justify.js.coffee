class @Editor.Controls.AlignJustify extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'align_justify'
    @icon = 'align-justify'
    @command = 'justifyfull'
    super

@Editor.Controls.register('align_justify', @Editor.Controls.AlignJustify)