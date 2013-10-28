class @Editor.Controls.FontControl extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate("editor.#{@caption}"))
    $button.html($('<i />', class: "fa fa-#{@icon}"))
    $button.tooltip(placement: 'top', container: 'body')
    $button.click ->
      $button.tooltip('hide')
    $button

  execCommand: ->
    document.execCommand(@command, false, null)

  queryActive: ->
    document.queryCommandState(@command, false, null)

  queryEnabled: ->
    try 
      document.queryCommandEnabled(@command, false, null)
    catch e

  querySupported: ->
    document.queryCommandSupported(@command, false, null)