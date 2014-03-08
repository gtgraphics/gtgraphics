AvailableControls = {}

@Editor.Controls =
  get: (key) ->
    AvailableControls[key]
  register: (key, controlClass) ->
    AvailableControls[key] = controlClass
  unregister: (key) ->
    delete AvailableControls[key]


class @Editor.Controls.Control
  constructor: ($toolbar) ->
    @toolbar = $toolbar

    @control = @createControl()
    @control.appendTo(@toolbar)
    @control.data('control', @)

    # @applyEvents()

    @deactivate()
    @enable()

  # TODO Das zur Editor-Klasse verschieben, da eine Control nicht nur auf einem Editor verwendet werden kann!!
  # applyEvents: ->
  #   @control.click (event) =>
  #     event.preventDefault()
  #     @control.trigger('executingCommand.editor')
  #   @executeCommand =>
  #     @editor.setChanged()
  #     @editor.region.focus().triggerHandler('focus')
  #     @control.trigger('executedCommand.editor')

  # @refreshState()
  # @control.on 'click', =>
  #   @refreshState()
  # @editor.region.on 'click focus blur textchange', =>
  #   @refreshState()

  createControl: ->
    $('<button />', type: 'button', class: 'btn btn-default btn-sm', tabindex: '-1')

  executeCommand: (editor, callback) ->
    @executeCommandSync(editor)
    callback()

  executeCommandSync: (editor) ->
    console.warn 'executeCommand() or executeCommandSync() have not been implemented'

  queryActive: ->
    false

  queryEnabled: ->
    true

  querySupported: ->
    true

  activate: ->
    @control.addClass('active')
    @active = true

  deactivate: ->
    @control.removeClass('active')
    @active = false

  enable: ->
    @control.prop('disabled', false)
    @disabled = false

  disable: ->
    @control.prop('disabled', true)
    @disabled = true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()

  refreshState: ->
    if @querySupported() and @queryEnabled()
      @enable()
      if @queryActive()
        @activate()
      else
        @deactivate()
    else
      @disable()
    true