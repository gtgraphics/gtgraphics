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
    @control = @create()
    @control.data('control', @)
    @control.appendTo(@controls)
    
    @control.click (event) =>
      event.preventDefault()
      @execCommand()
      @editor.setChanged()
      @editor.element.focus().triggerHandler('focus')

    # TODO Track Editor Changes and then document.queryCommandState
    # in order to determine whether this control is active or not
    #@editor.
    @editor.element.on 'blur click focus keyup paste', =>
      if @queryState()
        @activate()
      else
        @deactivate()
      true

    @deactivate()
    @enable()

  create: ->
    $('<button />', type: 'button', class: 'btn btn-default btn-mini', tabindex: '-1')

  execCommand: ->
    console.log.warn 'no action has been implemented'

  queryState: ->

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
