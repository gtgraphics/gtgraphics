class @Editor.Controls.AlignJustify extends @Editor.Controls.FontControl
  constructor: ->
    @caption = 'alignJustify'
    @icon = 'align-justify'
    @command = 'justifyfull'
    super

@Editor.Controls.register('alignJustify', @Editor.Controls.AlignJustify)