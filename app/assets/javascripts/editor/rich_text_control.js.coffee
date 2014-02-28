class @Editor.Controls.RichTextControl extends @Editor.Controls.Control
  constructor: ->
    super
    @isRichTextControl = true
    @disable()