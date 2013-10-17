class @Editor.Controls.AlignLeft extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.align_left'))
    $button.html($('<i />', class: 'icon-align-left'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('justifyleft', false, null)

  queryActive: ->
    document.queryCommandState('justifyleft')

  queryEnabled: ->
    document.queryCommandEnabled('justifyleft')

@Editor.Controls.register('align_left', @Editor.Controls.AlignLeft)