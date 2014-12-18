TIMEOUT_STORE_KEY = 'idleTimeout'

DEFAULTS =
  after: 5000
  idleClass: 'idle'
  awakeClass: null
  idleOnInit: false

setIdle = ($element, options) ->
  console.debug 'idle'
  $element.addClass(options.idleClass).removeClass(options.awakeClass)
  $element.trigger('idle')
  $element.data('isIdle', true)

setAwake = ($element, options) ->
  console.debug 'awaken'
  $element.removeClass(options.idleClass).addClass(options.awakeClass)
  $element.trigger('awake')
  $element.removeData('isIdle')

isIdle = ($element) ->
  $element.data('isIdle')

jQuery.fn.idleTimeoutable = (options = {}) ->
  @each ->
    $element = $(@)

    elementOpts = _(_(options).defaults($element.data())).defaults(DEFAULTS)

    if elementOpts.idleOnInit
      setIdle($element, elementOpts)
    else
      setAwake($element, elementOpts)

    timeout = $element.data(TIMEOUT_STORE_KEY)

    startTimeout = ->
      timeout = setTimeout ->
        setIdle($element, elementOpts)
      , elementOpts.after
      $element.data(TIMEOUT_STORE_KEY, timeout)
      timeout

    awaken = ->
      clearTimeout(timeout) if timeout
      timeout = null
      $element.removeData(TIMEOUT_STORE_KEY)
      setAwake($element, elementOpts) if isIdle($element)
      startTimeout()

    $element.mousemove -> awaken()
    $(document).keydown -> awaken()

    startTimeout()
