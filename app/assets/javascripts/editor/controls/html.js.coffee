class @Editor.Controls.Html extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = false

  create: ->
    $button = super
    $button.addClass('pull-right')
    #$button.attr('title', I18n.translate('editor.underline'))
    $button.text(I18n.translate('editor.html'))
    #$button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    @editor.html = !@editor.html
    if @editor.html
      @editor.element.hide()
      @editor.input.show().focus()
    else
      @editor.input.hide()
      @editor.element.show().focus()

    @editor.controls.forEach (control) =>
      if control.isRichTextControl
        if @editor.html
          control.disable()
        else
          control.enable()

    console.log @editor

  queryState: ->
    @editor.html == true

@Editor.Controls.register('html', @Editor.Controls.Html)