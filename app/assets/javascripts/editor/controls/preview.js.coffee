class @Editor.Controls.Preview extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = false

  createControl: ->
    $button = super
    $button.addClass('pull-right')
    $button.text(I18n.translate('editor.preview'))
    $button

  execCommand: ->
    @editor.contentEditable = !@editor.contentEditable
    if @editor.contentEditable
      @editor.region.removeAttr('contenteditable')
    else
      @editor.region.attr('contenteditable', true)

  queryActive: ->
    @editor.contentEditable == true

@Editor.Controls.register('preview', @Editor.Controls.Preview)