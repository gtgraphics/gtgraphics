class @Editor.Control
  constructor: (toolbar) ->
    @toolbar = toolbar
    @controlGroup = null
    @refreshInternalState()

  render: ->
    unless @$control
      @$control = @createControl().data('control', @)
      @onCreateControl()
    @refreshControlState()
    @$control

  destroy: ->
    @$control.remove() if @$control
    @$control = null
    true

  createControl: ->
    jQuery.error 'createControl() has not been implemented'

  onCreateControl: ->

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
    @$control? and @$control != undefined

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

  onInitEditor: (editor) ->

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
    if @$control
      @refreshControlState()
      @$control.trigger('editor:control:activated', @)
    true

  deactivate: ->
    @active = false
    if @$control
      @refreshControlState()
      @$control.trigger('editor:control:deactivated', @)
    true

  enable: ->
    @disabled = false
    if @$control
      @refreshControlState()
      @$control.trigger('editor:control:enabled', @)
    true

  disable: (disabled = true) ->
    @disabled = disabled
    if @$control
      @refreshControlState()
      @$control.trigger('editor:control:disabled', @)
    true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()

  # Getters

  getActiveEditor: ->
    @toolbar.activeEditor

availableControls = []

_(@Editor.Control).extend
  get: (key) ->
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
