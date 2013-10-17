class @Editor.Controls.AlignJustify extends @Editor.Controls.RichTextControl
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.align_justify'))
    $button.html($('<i />', class: 'icon-align-justify'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('justifyfull', false, null)

  queryActive: ->
    document.queryCommandState('justifyfull')

  queryEnabled: ->
    document.queryCommandEnabled('justifyfull')

@Editor.Controls.register('align_justify', @Editor.Controls.AlignJustify)