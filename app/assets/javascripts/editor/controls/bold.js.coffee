class @Editor.Controls.Bold extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.bold'))
    $button.html($('<i />', class: 'icon-bold'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('bold', false, null)

  queryActive: ->
    document.queryCommandState('bold')

  queryEnabled: ->
    document.queryCommandEnabled('bold')

@Editor.Controls.register('bold', @Editor.Controls.Bold)