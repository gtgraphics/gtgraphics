class @Editor.Control.FontControl extends @Editor.Control.ButtonControl
  getCommand: ->
    console.error 'no command defined for control'

  executeCommandSync: ->
    doc = @getRegionDocument()
    doc.execCommand(@getCommand(), false, null) if doc and @isInRichTextView()

  queryActive: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandState(@getCommand(), false, null)
    else
      false

  queryEnabled: ->
    try 
      doc = @getRegionDocument()
      if doc and @isInRichTextView()
        doc.queryCommandEnabled(@getCommand(), false, null)
      else
        false
    catch e
      false

  querySupported: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandSupported(@getCommand(), false, null)
    else
      false

  isInRichTextView: ->
    @toolbar.activeEditor and @toolbar.activeEditor.options.viewMode == 'richText'

  getRegionDocument: ->
    if @toolbar.activeEditor and @toolbar.activeEditor.isRendered()
      @toolbar.activeEditor.$regionFrame.get(0).contentDocument

  # createControl: ->
  #   $button = super
  #   # TODO Refresh when the selection in the target region becomes updated (focus blur textchange)
  #   $button
