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
