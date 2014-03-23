class @Editor.Control.DialogButtonControl extends @Editor.Control.ButtonControl
  executeCommand: (callback) ->
    # TODO Wait for modal to dispose and then trigger callback
    callback()

  executeCommandSync: ->
    console.warn 'executeCommandSync() is not available in this context'

  onExecute: ->
    # TODO Create and show modal and load content

  onExecuted: ->
    # TODO Hide modal
    @$modal = null

  createModal: ->
    @$modal = $('')