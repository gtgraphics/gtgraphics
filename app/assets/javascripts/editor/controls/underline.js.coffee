class @Editor.Controls.Underline extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = true
    
  create: ->
    $button = super
    $button.attr('title', I18n.translate('editor.underline'))
    $button.html($('<i />', class: 'icon-underline'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    document.execCommand('underline', false, null)

  queryState: ->
    document.queryCommandState('underline')

@Editor.Controls.register('underline', @Editor.Controls.Underline)