class @Editor.Controls.Italic extends @Editor.Controls.RichTextControl   
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.italic'))
    $button.html($('<i />', class: 'icon-italic'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('italic', false, null)

  queryActive: ->
    document.queryCommandState('italic')

  queryEnabled: ->
    document.queryCommandEnabled('italic')

@Editor.Controls.register('italic', @Editor.Controls.Italic)