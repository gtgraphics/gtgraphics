AvailableControls = {}

@Editor.Controls =
  get: (key) ->
    AvailableControls[key]
  register: (key, controlClass) ->
    AvailableControls[key] = controlClass
  unregister: (key) ->
    delete AvailableControls[key]

class @Editor.Controls.Base
  constructor: (@editor, $controls) ->
    @controls = $controls

    @control = @createControl()
    @control.appendTo(@controls)

    @control.data('control', @)
    @control.click (event) =>
      event.preventDefault()
      @execCommand()
      @editor.setChanged()
      @editor.element.focus().triggerHandler('focus')

    @refreshState()
    @editor.element.on 'blur click focus keyup paste', =>
      @refreshState()

    @deactivate()
    @enable()

  createControl: ->
    $('<button />', type: 'button', class: 'btn btn-default btn-mini', tabindex: '-1')

  execCommand: ->
    console.log.warn 'no action has been implemented'

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
