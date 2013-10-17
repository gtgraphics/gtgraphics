class @Editor.Controls.RichTextControl extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = true
    @disable()