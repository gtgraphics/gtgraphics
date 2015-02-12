jQuery.idleTimeoutable =
  defaults:
    after: 5000
    idleClass: 'idle'
    awakeClass: null
    idleOnInit: false
    target: 'body'
    awakeOn: ['keydown', 'mousedown', 'mousemove']
    if: null


class IdleTimeoutable
  constructor: ($element, options = {}) ->
    @$element = $element
    @options = _(_(options).defaults($element.data())).defaults(
      jQuery.idleTimeoutable.defaults
    )
    console.log @options
    @$target = $(@options.target)

    if _(@options.awakeOn).isArray()
      @awakeOn = @options.awakeOn
    else
      @awakeOn = [@options.awakeOn]
    @awakeOn = _(@awakeOn).compact()

    @timeout = null
    if @options.idleOnInit
      @idle()
    else
      @awaken()

  idle: ->
    return false if @isIdle == true
    return false if @options.if && !@options.if.apply(@)
    @$element.addClass(@options.idleClass).removeClass(@options.awakeClass)
    @$element.trigger('idle')
    @isIdle = true
    true

  awaken: ->
    return false if @isIdle == false
    @$element.removeClass(@options.idleClass).addClass(@options.awakeClass)
    @$element.trigger('awake')
    @isIdle = false
    true

  toggle: ->
    @stop()
    if @isIdle
      @awaken()
    else
      @idle()
    @start()
    true

  start: ->
    @stop()
    @startTimeout()
    @attachEvents()
    true

  stop: ->
    @stopTimeout()
    @detachEvents()
    true

  restart: ->
    @stop()
    @start()

  destroy: ->
    @stop()

  startTimeout: ->
    @timeout = setTimeout =>
      @idle()
    , @options.after

  stopTimeout: ->
    return unless @timeout
    clearTimeout(@timeout)
    @timeout = null

  attachEvents: ->
    @reactivationHandler = =>
      @stopTimeout()
      @awaken()
      @startTimeout()
      true

    # Mousemove
    if _(@awakeOn).contains('mousemove')
      @mouseMoveReactivationHandler = (event) =>
        currentMousePosition = "#{event.clientX}x#{event.clientY}"
        if currentMousePosition != @lastMousePosition
          @reactivationHandler()
          @lastMousePosition = currentMousePosition
        true
      @$target.on 'mousemove', @mouseMoveReactivationHandler

    # Mousedown
    if _(@awakeOn).contains('mousedown')
      @$target.on 'mousedown', @reactivationHandler

    # Keydown
    if _(@awakeOn).contains('keydown')
      @$target.on 'keydown', @reactivationHandler

    # Touch Start
    if _(@awakeOn).contains('tap')
      @$target.swipe(tap: @reactivationHandler, threshold: 50)

    # Window events
    $(window).on 'scroll resize', @reactivationHandler

  detachEvents: ->
    # Mousemove
    if _(@awakeOn).contains('mousemove') && @mouseMoveReactivationHandler
      @$target.off 'mousemove', @mouseMoveReactivationHandler

    if @reactivationHandler
      # Mousedown
      if _(@awakeOn).contains('mousedown')
        @$target.off 'mousedown', @reactivationHandler

      # Keydown
      if _(@awakeOn).contains('keydown')
        @$target.off 'keydown', @reactivationHandler

      # Touch Start
      if _(@awakeOn).contains('tap')
        @$target.off 'tap', @reactivationHandler

      # Window events
      $(window).off 'scroll resize', @reactivationHandler

    # Remove event handler functions
    @mouseMoveReactivationHandler = null
    @reactivationHandler = null


jQuery.fn.idleTimeoutable = (methodOrOptions = {}) ->
  @each ->
    $element = $(@)

    timeoutable = $element.data('idleTimeoutable')

    if jQuery.isPlainObject(methodOrOptions)
      # initializes the IdleTimeoutable object and starts the timeout
      jQuery.error 'idleTimeoutable already initialized' if timeoutable
      timeoutable = new IdleTimeoutable($element, methodOrOptions)
      timeoutable.start()
      $element.data('idleTimeoutable', timeoutable)
    else
      # makes a method call on an existing IdleTimeoutable object
      jQuery.error 'idleTimeoutable not initialized' unless timeoutable
      args = Array.prototype.slice.call(arguments, 0)
      timeoutable[methodOrOptions].apply(timeoutable, args.slice(1))
