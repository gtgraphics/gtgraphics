class @Editor.Controls.Underline extends @Editor.Controls.RichTextControl   
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.underline'))
    $button.html($('<i />', class: 'icon-underline'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('underline', false, null)

  queryActive: ->
    document.queryCommandState('underline')

  queryEnabled: ->
    document.queryCommandEnabled('underline')

@Editor.Controls.register('underline', @Editor.Controls.Underline)