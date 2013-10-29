class @Editor.Controls.Image extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = 'image'
    @icon = 'picture-o'
    super

  execCommand: ->
    Editor.active = @editor
    @editor.currentControl = @

    selection = @editor.getSelection()
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    $anchor = @editor.getSelectedNode()
    if $anchor.is('img')
      url = $anchor.attr('src')
      alternativeText = $anchor.attr('alt')
    else
      #

    jQuery.ajax
      url: '/admin/editor/image'
      data: { url: url, alternative_text: alternativeText }
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
    if $anchor.is('img')
      $anchor.replaceWith(html)
    else
      @editor.pasteHtml(html)

  queryActive: ->
    @editor.getSelectedNode().is('img')

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


@Editor.Controls.register('image', @Editor.Controls.Image)