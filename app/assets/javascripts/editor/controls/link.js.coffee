class @Editor.Controls.Link extends @Editor.Controls.Base
  constructor: ->
    super
    @isRichTextControl = false

  createControl: ->
    $button = super
    $button.attr('title', I18n.translate('editor.link'))
    $button.html($('<i />', class: 'fa fa-link'))
    $button.tooltip(placement: 'top', container: 'body')
    $button

  execCommand: ->
    alert 'Open Modal'

  queryActive: ->
    false

  queryEnabled: ->
    false
    
  querySupported: ->
    false

@Editor.Controls.register('link', @Editor.Controls.Link)