class @Editor.Control.Link extends @Editor.Control.ModalControl
  constructor: ->
    @caption = @icon = 'link'
    @url = "/#{I18n.locale}/admin/editor/link"
    @selector = 'a[href]'
    super

@Editor.Control.register('link', @Editor.Control.Link)