class @Editor.Control.FontControl extends @Editor.Control.ButtonControl
  getCommand: ->
    console.error 'no command defined for control'

  executeCommandSync: ->
    doc = @getRegionDocument()
    doc.execCommand(@getCommand(), false, null) if doc

  queryActive: ->
    doc = @getRegionDocument()
    if doc
      doc.queryCommandState(@getCommand(), false, null)
    else
      false

  queryEnabled: ->
    try 
      doc = @getRegionDocument()
      if doc
        doc.queryCommandEnabled(@getCommand(), false, null)
      else
        false
    catch e
      false

  querySupported: ->
    doc = @getRegionDocument()
    if doc
      doc.queryCommandSupported(@getCommand(), false, null)
    else
      false

  getRegionDocument: ->
    if @toolbar.activeEditor and @toolbar.activeEditor.isRendered()
      @toolbar.activeEditor.$regionFrame.get(0).contentDocument

  # createControl: ->
  #   $button = super
  #   # TODO Refresh when the selection in the target region becomes updated (focus blur textchange)
  #   $button
