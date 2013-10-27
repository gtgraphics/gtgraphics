class @Editor.Controls.Link extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = 'link'
    @command = 'createlink'
    @isRichTextControl = false
    super

  execCommand: ->
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()

    jQuery.ajax
      url: '/admin/editor/link'
      data: { target: @editor.input.attr('id') }
      dataType: 'html'
      success: (html) =>
        $modalContainer.html(html)
        $modal = $modalContainer.find('.modal')
        $modal.data('owner', @)
        @editor.currentModal = $modal
        $modal.modal('show')

      #$modalContainer.on 'hide.bs.modal', =>
        #@editor.restoreSelection()

    $modalContainer.on 'hidden.bs.modal', =>
      $modal = $modalContainer.find('.modal')
      $modal.remove()
      @editor.currentModal = null

  execCommandSuccess: (record) ->
    @editor.restoreSelection()
    @editor.region.focus()

    $modalContainer = @findOrCreateModalContainer()
    $modal = $modalContainer.find('.modal')
    $modal.modal('hide')

  execCommandError: ->
    

  execCommandComplete: ->
    
  findOrCreateModalContainer: ->
    $modalContainer = $('#editor_modal_container')
    if $modalContainer.length == 0
      $modalContainer = $('<div />', id: 'editor_modal_container')
      $modalContainer.appendTo('body')
    $modalContainer


@Editor.Controls.register('link', @Editor.Controls.Link)