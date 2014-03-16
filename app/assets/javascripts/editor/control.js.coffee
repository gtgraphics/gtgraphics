class @Editor.Controls.Control
  constructor: (toolbar) ->
    @toolbar = toolbar
    @group = null
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

  executeCommand: (callback) ->
    returnValue = @executeCommandSync()
    callback() if callback
    returnValue

  executeCommandSync: ->
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
      @$control.trigger('activated.control.editor', @)
    true

  deactivate: ->
    @active = false
    if @$control
      @refreshControlState()
      @$control.trigger('deactivated.control.editor', @)
    true

  enable: ->
    @disabled = false
    if @$control
      @refreshControlState()
      @$control.trigger('enabled.control.editor', @)
    true

  disable: (disabled = true) ->
    @disabled = disabled
    if @$control
      @refreshControlState()
      @$control.trigger('disabled.control.editor', @)
    true

  toggle: ->
    if @active
      @deactivate()
    else
      @activate()