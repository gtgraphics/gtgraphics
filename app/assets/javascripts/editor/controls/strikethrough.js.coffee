class @Editor.Controls.Strikethrough extends @Editor.Controls.RichTextControl   
  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.strikethrough'))
    $button.html($('<i />', class: 'fa fa-strikethrough'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('strikethrough', false, null)

  queryActive: ->
    document.queryCommandState('strikethrough')

  queryEnabled: ->
    document.queryCommandEnabled('strikethrough')

@Editor.Controls.register('strikethrough', @Editor.Controls.Strikethrough)