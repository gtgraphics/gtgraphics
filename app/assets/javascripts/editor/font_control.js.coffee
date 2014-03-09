class @Editor.Controls.FontControl extends @Editor.Controls.ButtonControl
  getCommand: ->
    jQuery.error 'no command defined for control'

  executeCommandSync: ->
    document.execCommand(@getCommand(), false, null)

  queryActive: ->
    document.queryCommandState(@getCommand(), false, null)

  queryEnabled: ->
    try 
      document.queryCommandEnabled(@getCommand(), false, null)
    catch e

  querySupported: ->
    document.queryCommandSupported(@getCommand(), false, null)

  createControl: ->
    $button = super
    # TODO Refresh when the selection in the target region becomes updated (focus blur textchange)
    $button
