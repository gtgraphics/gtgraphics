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
  constructor: ->
    @refreshInternalState()

  render: ->
    unless @renderedControl
      $control = @createControl()
      $control.data('control', @)
      @renderedControl = $control
    @refreshControlState()
    @renderedControl

  destroy: ->
    @renderedControl.remove() if @renderedControl
    @renderedControl = null

  createControl: ->
    jQuery.error 'createControl() has not been implemented'

  executeCommand: (callback) ->
    returnValue = @executeCommandSync()
    callback() if callback
    returnValue

  executeCommandSync: ->
    console.warn 'executeCommand() or executeCommandSync() have not been implemented'

  # Refreshers

  refresh: ->
    @refreshInternalState()
    @refreshControlState() if @renderedControl

  refreshInternalState: ->
    if @querySupported() and @queryEnabled()
      @disabled = false
      if @queryActive()
        @active = true
      else
        @active = false
    else
      @disabled = true
    true

  refreshControlState: ->
    console.warn 'refreshControlState() has not been implemented'

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
      @refreshControlState()
      @renderedControl.trigger('activated.control.editor', @)
    true

  deactivate: ->
    @active = false
    if @renderedControl
      @refreshControlState()
      @renderedControl.trigger('deactivated.control.editor', @)
    true

  enable: ->
    @disabled = false
    if @renderedControl
      @refreshControlState()
      @renderedControl.trigger('enabled.control.editor', @)
    true

  disable: (disabled = true) ->
    @disabled = disabled
    if @renderedControl
      @refreshControlState()
      @renderedControl.trigger('disabled.control.editor', @)
    true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()