$(document).ready ->

  $body = $('body')
  $body.addClass('editing')

  # TODO Add Toolbar
  
  $toolbarWrapper = $('<div />', id: 'editor_toolbar', class: 'editor-controls').appendTo($body)
  $toolbarContainer = $('<div />', class: 'container').appendTo($toolbarWrapper)

  toolbar = new Editor.Toolbar()
  $toolbar = toolbar.render() 
  $toolbar.appendTo($toolbarContainer)

  $('.region', $body).editor(class: RegionEditor, toolbar: $toolbar)
