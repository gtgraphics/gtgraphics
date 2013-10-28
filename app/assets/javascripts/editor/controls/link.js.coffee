class @Editor.Controls.Link extends @Editor.Controls.AsyncFontControl
  constructor: ->
    @caption = @icon = 'link'
    @command = 'createlink'
    @isRichTextControl = false
    super

  execCommand: ->
    selection = @editor.getSelection()
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    $anchor = @editor.getSelectedNode()
    target = @editor.input.attr('id')
    if $anchor.is('a[href]')
      caption = $anchor.text()
      url = $anchor.attr('href')
      newWindow = $anchor.attr('target') == '_blank'
    else
      caption = selection.toString()

    jQuery.ajax
      url: '/admin/editor/link'
      data: { target: target, caption: caption, url: url, new_window: newWindow }
      dataType: 'html'
      success: (html) =>
        $modalContainer.html(html)
        $modal = $modalContainer.find('.modal')
        $modal.data('owner', @)
        $modal.modal('show')
        @editor.currentModal = $modal

    $modalContainer.on 'hidden.bs.modal', =>
      $modal = $modalContainer.find('.modal')
      $modal.remove()
      @editor.currentModal = null

  execCommandSuccess: (html) ->
    $modalContainer = @findOrCreateModalContainer()
    $modalContainer.find('.modal').modal('hide')

    @editor.restoreSelection()
    @editor.storeSelection()
    $anchor = @editor.getSelectedNode()
    if $anchor.is('a[href]')
      $anchor.replaceWith(html)
    else
      @editor.pasteHtml(html)
    @editor.restoreSelection()
    
  execCommandInvalid: ->

  execCommandComplete: ->
    
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