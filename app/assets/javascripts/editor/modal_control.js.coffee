class @Editor.Controls.ModalControl extends @Editor.Controls.AsyncFontControl
  execCommand: (callback) ->
    Editor.active = @editor
    @editor.currentControl = @

    selection = @editor.getSelection()
    @editor.storeSelection()

    $node = @editor.getSelectedNodeParent()
    if $node.is(@selector)
      html = $node.get(0).outerHTML
    else
      html = selection.toString()

    $modalContainer = @findOrCreateModalContainer()
    
    jQuery.ajax
      url: @url
      data: { html: html }
      dataType: 'html'
      success: (html) =>
        $modalContainer.html(html)
        $modal = $modalContainer.find('.modal').modal('show')
        @editor.currentModal = $modal

        @editor.restoreSelection()

        $node = @editor.getSelectedNode()
        if $node.is(@selector)
          $node.replaceWith(html)
        else
          @editor.pasteHtml(html)

        callback()

  queryActive: ->
    @editor.getSelectedNode().is(@selector)

  queryEnabled: ->
    @editor.viewMode == 'editor'

  querySupported: ->
    true

  findOrCreateModalContainer: ->
    $modalContainer = $('#editor_modal_container')
    if $modalContainer.length == 0
      $modalContainer = $('<div />', id: 'editor_modal_container')
      $modalContainer.appendTo('body')
      $modalContainer.on 'hidden.bs.modal', =>
        $modalContainer.find('.modal').remove()
        @editor.currentControl = null
        @editor.currentModal = null
        Editor.active = null
        @editor.setChanged()
    $modalContainer