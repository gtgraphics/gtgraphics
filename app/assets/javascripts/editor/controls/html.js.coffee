class @Editor.Controls.Html extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = false

  createControl: ->
    $button = super
    $button.addClass('pull-right')
    $button.text(I18n.translate('editor.html'))
    $button

  execCommand: ->
    @editor.html = !@editor.html
    if @editor.html
      @editor.region.hide()
      @editor.input.show().focus()
      @editor.input.outerHeight(@editor.region.outerHeight(true))
    else
      @editor.input.hide()
      @editor.region.show().focus()
      @editor.region.outerHeight(@editor.input.outerHeight(true))

    @editor.controls.forEach (control) ->
      control.refreshState()

  queryActive: ->
    @editor.html == true

@Editor.Controls.register('html', @Editor.Controls.Html)