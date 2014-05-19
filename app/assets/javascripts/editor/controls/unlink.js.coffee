class @Editor.Control.Unlink extends @Editor.Control.FontControl
  ELEMENT_SELECTOR = 'a[href]'

  getCommand: ->
    'unlink'

  getCaption: ->
    I18n.translate('javascript.editor.unlink')

  getIcon: ->
    'unlink'

  executeCommandSync: ->
    $content = @getClosestAnchor().contents().unwrap()
    firstChild = $content.first().get(0)
    lastChild = $content.last().get(0)
    @getActiveEditor().setSelectionAroundNodes(firstChild, lastChild)

  queryEnabled: ->
    @getClosestAnchor().any()

  getClosestAnchor: ->
    editor = @getActiveEditor()
    if editor
      range = editor.getSelectedRange()
      $(range.getNodes()).filter(ELEMENT_SELECTOR).add($(range.commonAncestorContainer).closest(ELEMENT_SELECTOR)).first()
    else
      jQuery()
      
@Editor.Control.register('unlink', @Editor.Control.Unlink)