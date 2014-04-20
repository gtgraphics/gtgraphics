$(document).ready ->

  $body = $('body')

  $body.addClass('editing')

  # TODO Add Toolbar
  
  $toolbarWrapper = $('<div />', id: 'editor_toolbar', class: 'editor-controls').appendTo($body)
  $toolbarContainer = $('<div />', class: 'container').appendTo($toolbarWrapper)


  controls = [
    ['save'],
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['pageSettings', 'html']
  ]

  #toolbar = new Editor.Toolbar(controls: controls)
  #$toolbar = toolbar.render() 
  #$toolbar.appendTo($toolbarContainer)

  $page = $('#editor_frame')
  pageDocument = $page.get(0).contentDocument
  $(pageDocument).on 'page:load', (event) ->
    console.log(pageDocument.location.pathname)