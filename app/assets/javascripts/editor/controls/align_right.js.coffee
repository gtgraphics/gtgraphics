class @Editor.Controls.AlignRight extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.align_right'))
    $button.html($('<i />', class: 'fa fa-align-right'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('justifyright', false, null)

  queryActive: ->
    document.queryCommandState('justifyright')

  queryEnabled: ->
    document.queryCommandEnabled('justifyright')

@Editor.Controls.register('align_right', @Editor.Controls.AlignRight)