class @Editor.Controls.Bold extends @Editor.Controls.Base
  create: ->
    $button = super
    $button.attr('title', I18n.translate('editor.bold'))
    $button.html($('<i />', class: 'icon-bold'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('bold', false, null)

  queryState: ->
    document.queryCommandState('bold')

@Editor.Controls.register('bold', @Editor.Controls.Bold)