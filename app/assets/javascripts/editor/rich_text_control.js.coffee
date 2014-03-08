class @Editor.Controls.RichTextControl extends @Editor.Controls.Control
  constructor: ($toolbar) ->
    super
    @isRichTextControl = true
    @disable()

  createControl: ->
    $button = super
    $button.attr('title', I18n.translate("editor.#{@caption}"))
    $button.html($('<i />', class: "fa fa-#{@icon}"))
    $button.tooltip(placement: 'top', container: 'body')
    $button.click ->
      $button.tooltip('destroy')
    $button