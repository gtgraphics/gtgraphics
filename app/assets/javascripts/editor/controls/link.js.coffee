class @Editor.Controls.Link extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = @icon = 'link'
    super

  execCommand: ->
    Editor.active = @editor
    @editor.currentControl = @

    selection = @editor.getSelection()
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    $anchor = @editor.getSelectedNode()
    if $anchor.is('a[href]')
      html = $anchor.get(0).outerHTML
    else
      html = selection.toString()
    
    jQuery.ajax
      url: "/#{I18n.locale}/admin/editor/link"
      #data: { caption: caption, url: url, target: target }
      data: { html: html }
      dataType: 'html'
      success: (html) =>
        $modalContainer.html(html)
        $modal = $modalContainer.find('.modal')
        $modal.modal('show')
        @editor.currentModal = $modal

    $modalContainer.on 'hidden.bs.modal', =>
      $modalContainer.find('.modal').remove()
      @editor.currentControl = null
      @editor.currentModal = null
      Editor.active = null
      @editor.setChanged()

  execCommandCallback: (html) ->
    $modalContainer = @findOrCreateModalContainer()
    $modalContainer.find('.modal').modal('hide')

    @editor.restoreSelection()

    $anchor = @editor.getSelectedNode()
    if $anchor.is('a[href]')
      $anchor.replaceWith(html)
    else
      @editor.pasteHtml(html)

  queryActive: ->
    @editor.getSelectedNode().is('a[href]')

  queryEnabled: ->
    @editor.viewMode == 'editor'

  querySupported: ->
    true

  findOrCreateModalContainer: ->
    $modalContainer = $('#editor_modal_container')
    if $modalContainer.length == 0
      $modalContainer = $('<div />', id: 'editor_modal_container')
      $modalContainer.appendTo('body')
    $modalContainer


@Editor.Controls.register('link', @Editor.Controls.Link)