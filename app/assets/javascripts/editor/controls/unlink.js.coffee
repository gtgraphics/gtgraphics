class @Editor.Controls.Unlink extends @Editor.Controls.FontControl
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

@Editor.Controls.register('unlink', @Editor.Controls.Unlink)