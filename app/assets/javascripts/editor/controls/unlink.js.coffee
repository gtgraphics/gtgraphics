class @Editor.Control.Unlink extends @Editor.Control.FontControl
  ELEMENT_SELECTOR = 'a[href]'

  getCommand: ->
    'unlink'

  getCaption: ->
    I18n.translate('editor.unlink')

  getIcon: ->
    'unlink'

  executeCommandSync: ->
    $content = @getClosestAnchor().contents().unwrap()
    @getActiveEditor().setSelectionAroundNodes($content.first().get(0), $content.last().get(0))

  queryEnabled: ->
    @getClosestAnchor().any()

  getClosestAnchor: ->
    range = @getActiveEditor().getSelectedRange()
    $(range.getNodes()).filter(ELEMENT_SELECTOR)
    #$(range.commonAncestorContainer).closest(ELEMENT_SELECTOR)

@Editor.Control.register('unlink', @Editor.Control.Unlink)