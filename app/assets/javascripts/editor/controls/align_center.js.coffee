class @Editor.Controls.AlignCenter extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.align_center'))
    $button.html($('<i />', class: 'icon-align-center'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('justifycenter', false, null)

  queryActive: ->
    document.queryCommandState('justifycenter')

  queryEnabled: ->
    document.queryCommandEnabled('justifycenter')

@Editor.Controls.register('align_center', @Editor.Controls.AlignCenter)