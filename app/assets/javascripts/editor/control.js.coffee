class @Editor.Control
  constructor: (toolbar) ->
    @toolbar = toolbar
    @controlGroup = null
    @refreshInternalState()

  render: ->
    unless @$control
      @$control = @createControl()
      @getControl().data('control', @)
      @onCreateControl()
    @refreshControlState()
    @$control

  destroy: ->
    @$control.remove() if @$control
    @$control = null
    true

  getControl: ->
    @$control

  getControlContainer: ->
    @$control

  createControl: ->
    jQuery.error 'createControl() has not been implemented'

  onCreateControl: ->
    # may apply events to the control that has been created

  executeCommand: (callback, contextData = {}) ->
    returnValue = @executeCommandSync(contextData)
    callback()
    returnValue

  executeCommandSync: (contextData) ->
    console.warn 'executeCommand() or executeCommandSync() have not been implemented'

  # Refreshers

  refresh: ->
    @refreshInternalState()
    @refreshControlState() if @isRendered()

  isRendered: ->
    @$control? && @$control != undefined

  refreshInternalState: ->
    if @querySupported() && @queryEnabled()
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

  onInitEditor: (editor) ->

  # when updateState is invoked, queryActive determines whether this input has an active state
  queryActive: ->
    false

  # when updateState is invoked, queryEnabled determines whether this input has an enabled state
  queryEnabled: ->
    true

  # when updateState is invoked, querySupported determines whether this input has a supported state
  querySupported: ->
    true

  # State Changers

  activate: (active = true) ->
    @active = active
    if @isRendered()
      @refreshControlState()
      @getControl().trigger('editor:control:activated', @)
    true

  deactivate: ->
    @active = false
    if @isRendered()
      @refreshControlState()
      @getControl().trigger('editor:control:deactivated', @)
    true

  enable: ->
    @disabled = false
    if @isRendered()
      @refreshControlState()
      @getControl().trigger('editor:control:enabled', @)
    true

  disable: (disabled = true) ->
    @disabled = disabled
    if @isRendered()
      @refreshControlState()
      @getControl().trigger('editor:control:disabled', @)
    true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()

  # Getters

  getActiveEditor: ->
    @toolbar.activeEditor

availableControls = {}

_(@Editor.Control).extend
  getControls: ->
    _(availableControls).values()

  getControlNames: ->
    _(availableControls).keys()

  load: ($control, toolbar) ->
    jQuery.error 'Control must be a jQuery object' unless $control instanceof jQuery
    control = $control.data('control')
    unless control? && control instanceof @Editor.Control
      controlName = $control.data('command')
      control = @init(controlName, toolbar)
      control.$control = $control
      control.onCreateControl() # triggers callback to act as if this control has been created
    control.refreshControlState()
    control

  get: (key) ->
    jQuery.error "No key specified" unless key
    control = availableControls[key]
    jQuery.error "Control not found: #{key}" unless control
    control

  init: (key, toolbar) ->
    klass = @get(key)
    new klass(toolbar)

  register: (key, controlClass) ->
    availableControls[key] = controlClass

  unregister: (key) ->
    delete availableControls[key]
