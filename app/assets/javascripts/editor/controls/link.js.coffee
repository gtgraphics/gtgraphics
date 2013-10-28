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

    jQuery.ajax
      url: '/admin/editor/link'
      data: { target: @editor.input.attr('id'), caption: selection.toString() }
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

  execCommandSuccess: (record) ->
    $modalContainer = @findOrCreateModalContainer()
    $modal = $modalContainer.find('.modal')
    $modal.modal('hide')

    @editor.restoreSelection()
    selection = @editor.getSelection()
    
    target = '_blank' if record.new_window
    $link = $('<a />', href: record.url, target: target).text(record.caption)
    @editor.pasteHtml($link)

  execCommandInvalid: ->

  execCommandComplete: ->
    
  findOrCreateModalContainer: ->
    $modalContainer = $('#editor_modal_container')
    if $modalContainer.length == 0
      $modalContainer = $('<div />', id: 'editor_modal_container')
      $modalContainer.appendTo('body')
    $modalContainer


@Editor.Controls.register('link', @Editor.Controls.Link)