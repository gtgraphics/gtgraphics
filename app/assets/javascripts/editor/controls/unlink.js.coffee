class @Editor.Control.Unlink extends @Editor.Control.FontControl
  constructor: ->
    @caption = @icon = @command = 'unlink'
    super

  execCommandSync: ->
    # http://stackoverflow.com/questions/11015313/get-caret-html-position-in-contenteditable-div
    @editor.storeSelection()
    $node = @editor.getSelectedNode()
    $node.replaceWith($node.text())
    @editor.restoreSelection()

  queryActive: ->
    false

  queryEnabled: ->
    @editor.getSelectedNode().is('a[href]')

  querySupported: ->
    true

@Editor.Control.register('unlink', @Editor.Control.Unlink)