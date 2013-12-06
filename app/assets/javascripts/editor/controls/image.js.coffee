class @Editor.Controls.Image extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = 'image'
    @icon = 'picture-o'
    super

    _this = @

    @editor.region.on 'click', 'img', =>

    @editor.region.on 'focus textchange', =>
      @unselectImage()

    $(document).on 'click', =>
      @unselectImage()

  execCommand: ->
    Editor.active = @editor
    @editor.currentControl = @

    selection = @editor.getSelection()
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    $image = $('img[data-editor-state="selected"]')

    jQuery.ajax
      url: '/admin/editor/image'
      data: { html: $image.html() }
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
    $image = $('img[data-editor-state="selected"]')
    $image.length > 0
    #@editor.getSelectedNode().is('img')

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