class @Editor.Controls.Italic extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = true
    
  create: ->
    $button = super
    $button.attr('title', I18n.translate('editor.italic'))
    $button.html($('<i />', class: 'icon-italic'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('italic', false, null)

  queryState: ->
    document.queryCommandState('italic')

@Editor.Controls.register('italic', @Editor.Controls.Italic)