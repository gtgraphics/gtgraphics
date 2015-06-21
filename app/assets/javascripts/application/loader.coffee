LOADER_SELECTOR = '#loader'
TRANSITION_DURATION = 200

@Loader =

  start: ->
    $(LOADER_SELECTOR).show().transition(opacity: 1, duration: TRANSITION_DURATION)

  done: ->
    $loader = $(LOADER_SELECTOR)
    $loader.transition opacity: 0, duration: TRANSITION_DURATION, ->
      $loader.hide()

  remove: ->
    $(LOADER_SELECTOR).remove()
