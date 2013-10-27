class @Editor.Controls.Link extends @Editor.Controls.FontControl
  constructor: ->
    @caption = @icon = 'link'
    @command = 'createlink'
    @isRichTextControl = false
    super

  execCommand: ->
    console.log 'execCommand link'
    @editor.storeSelection()

    $modalContainer = @findOrCreateModalContainer()
    $modalContainer.load '/admin/editor/link', =>
      $modal = $modalContainer.find('.modal')
      $modal.modal('show')

      #$form = $modal.find('.modal-content form')
      #$form.submit (event) =>
      #  event.preventDefault()
      #  formData = $form.serializeArray()
      #  console.log form
      #  @editor.restoreSelection()

      # document.execCommand('createlink', false, formData[2].value)
      # $modal.modal('hide')

      #$modalContainer.on 'hidden.bs.modal', ->
      #  $modal.modal('remove')

  findOrCreateModalContainer: ->
    $modalContainer = $('#editor_modal_container')
    if $modalContainer.length == 0
      $modalContainer = $('<div />', id: 'editor_modal_container')
      $modalContainer.appendTo('body')
    $modalContainer

@Editor.Controls.register('link', @Editor.Controls.Link)