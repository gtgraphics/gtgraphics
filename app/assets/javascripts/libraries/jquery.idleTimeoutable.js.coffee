jQuery.idleTimeoutable =
  defaults:
    after: 5000
    idleClass: 'idle'
    awakeClass: null
    idleOnInit: false
    target: 'body'
    awakeOn: 'mousedown mousemove'


class IdleTimeoutable
  constructor: ($element, options = {}) ->
    @$element = $element
    @options = _(_(options).defaults($element.data())).defaults(
      jQuery.idleTimeoutable.defaults
    )
    @$target = $(@options.target)

    @timeout = null
    if @options.idleOnInit
      @idle()
    else
      @awaken()

  idle: ->
    return if @isIdle == true
    @$element.addClass(@options.idleClass).removeClass(@options.awakeClass)
    @$element.trigger('idle')
    @isIdle = true

  awaken: ->
    return if @isIdle == false
    @$element.removeClass(@options.idleClass).addClass(@options.awakeClass)
    @$element.trigger('awake')
    @isIdle = false

  toggle: ->
    @stop()
    if @isIdle
      @awaken()
    else
      @idle()
    @start()

  start: ->
    @stop()
    @startTimeout()

    @reactivationHandler = =>
      @stopTimeout()
      @awaken()
      @startTimeout()

    @$target.on @options.awakeOn, @reactivationHandler
    $(window).on 'scroll resize', @reactivationHandler

  stop: ->
    @stopTimeout()
    if @reactivationHandler
      @$target.off @options.awakeOn, @reactivationHandler
      $(window).off 'scroll resize', @reactivationHandler
      @reactivationHandler = null

  startTimeout: ->
    @timeout = setTimeout =>
      @idle()
    , @options.after

  stopTimeout: ->
    return unless @timeout
    clearTimeout(@timeout)
    @timeout = null


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
