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
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandEnabled(@getCommand(), false, null)
    else
      false

  querySupported: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      doc.queryCommandSupported(@getCommand(), false, null)
    else
      false