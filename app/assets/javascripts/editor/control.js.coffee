AvailableControls = {}

@Editor.Controls =
  get: (key) ->
    control = AvailableControls[key]
    jQuery.error "Control not found: #{key}" unless control
    control
  init: (key) ->
    klass = @get(key)
    new klass()
  register: (key, controlClass) ->
    AvailableControls[key] = controlClass
  unregister: (key) ->
    delete AvailableControls[key]


class @Editor.Controls.Control

  # @refreshState()
  # @control.on 'click', =>
  #   @refreshState()
  # @editor.region.on 'click focus blur textchange', =>
  #   @refreshState()

  constructor: ->
    @updateState()

  render: ->
    unless @renderedControl
      $control = @createControl()
      $control.data('control', @)
      @renderedControl = $control
    @updateControlState()
    @renderedControl

  createControl: ->
    jQuery.error 'createControl() has not been implemented'

  executeCommand: (callback) ->
    returnValue = @executeCommandSync()
    callback() if callback
    returnValue

  executeCommandSync: ->
    console.warn 'executeCommand() or executeCommandSync() have not been implemented'

  # Refreshers

  updateState: ->
    if @querySupported() and @queryEnabled()
      @disabled = false
      if @queryActive()
        @active = true
      else
        @active = false
    else
      @disabled = true
    true

  updateControlState: ->
    console.warn 'updateControlState() has not been implemented'

  refresh: ->
    @updateState()
    @updateControlState()

  # when updateState is invoked, queryActive determines whether this input has an active state
  queryActive: ->
    false

  # when updateState is invoked, queryActive determines whether this input has an enabled state
  queryEnabled: ->
    true

  # when updateState is invoked, queryActive determines whether this input has a supported state
  querySupported: ->
    true

  # State Changers

  activate: (active = true) ->
    @active = active
    if @renderedControl
      @updateControlState()
      @renderedControl.trigger('activated.control.editor', @)
    true

  deactivate: ->
    @active = false
    if @renderedControl
      @updateControlState()
      @renderedControl.trigger('deactivated.control.editor', @)
    true

  enable: ->
    @disabled = false
    if @renderedControl
      @updateControlState()
      @renderedControl.trigger('enabled.control.editor', @)
    true

  disable: (disabled = true) ->
    @disabled = disabled
    if @renderedControl
      @updateControlState()
      @renderedControl.trigger('disabled.control.editor', @)
    true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()