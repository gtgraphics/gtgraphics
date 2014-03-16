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
    ['orderedList', 'unorderedList', 'indent', 'outdent']
  ]

  toolbar = new Editor.Toolbar(controls: controls, tooltip: { placement: 'bottom', container: '#editor_toolbar' })
  $toolbar = toolbar.render() 
  $toolbar.appendTo($toolbarContainer)

  $('.region').editor(class: RegionEditor, toolbar: $toolbar)
