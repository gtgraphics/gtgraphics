class @Editor.Controls.AsyncFontControl extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate("editor.#{@caption}"))
    $button.html($('<i />', class: "fa fa-#{@icon}"))
    $button.tooltip(placement: 'top', container: 'body')
    $button