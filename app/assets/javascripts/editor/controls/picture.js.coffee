class @Editor.Controls.Picture extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = 'picture'
    @icon = 'picture-o'
    super

  execCommand: ->
    Editor.active = @editor
    @editor.currentControl = @

    selection = @editor.getSelection()
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    $anchor = @editor.getSelectedNode()
    target = @editor.input.attr('id')
    if $anchor.is('a[href]')
      caption = $anchor.text()
      url = $anchor.attr('href')
      target = $anchor.attr('target')
    else
      caption = selection.toString()

    jQuery.ajax
      url: '/admin/editor/link'
      data: { caption: caption, url: url, target: target }
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


@Editor.Controls.register('picture', @Editor.Controls.Picture)