class @Editor.Control.FontControl extends @Editor.Control.ButtonControl
  getCommand: ->
    console.error 'no command defined for control'

  executeCommandSync: ->
    doc = @getRegionDocument()
    doc.execCommand(@getCommand(), false, null) if doc and @isInRichTextView()

  queryActive: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      try
        doc.queryCommandState(@getCommand(), false, null)
      catch
        false
    else
      false

  queryEnabled: ->
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      try
        doc.queryCommandEnabled(@getCommand(), false, null)
      catch
        false
    else
      false

  querySupported: ->
    return true
    doc = @getRegionDocument()
    if doc and @isInRichTextView()
      try
        doc.queryCommandSupported(@getCommand(), false, null)
      catch
        false
    else
      false