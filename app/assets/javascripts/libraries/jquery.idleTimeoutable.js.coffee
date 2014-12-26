TIMEOUT_STORE_KEY = 'idleTimeout'

DEFAULTS =
  after: 5000
  idleClass: 'idle'
  awakeClass: null
  idleOnInit: false
  target: 'body'

setIdle = ($element, options) ->
  $element.addClass(options.idleClass).removeClass(options.awakeClass)
  $element.trigger('idle')
  $element.data('isIdle', true)

setAwake = ($element, options) ->
  $element.removeClass(options.idleClass).addClass(options.awakeClass)
  $element.trigger('awake')
  $element.removeData('isIdle')

isIdle = ($element) ->
  $element.data('isIdle')

jQuery.fn.idleTimeoutable = (options = {}) ->
  @each ->
    $element = $(@)

    elementOpts = _(_(options).defaults($element.data())).defaults(DEFAULTS)

    $target = $(elementOpts.target)

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

    $target.mousemove -> awaken()
    $(document).keydown -> awaken()

    startTimeout()
