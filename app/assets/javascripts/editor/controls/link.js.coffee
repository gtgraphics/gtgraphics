class @Editor.Controls.Link extends @Editor.Controls.ModalControl
  constructor: ->
    @caption = @icon = 'link'
    @url = "/#{I18n.locale}/admin/editor/link"
    @selector = 'a[href]'
    super

@Editor.Controls.register('link', @Editor.Controls.Link)