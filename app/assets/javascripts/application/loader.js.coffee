LOADER_SELECTOR = '#loader'
TRANSITION_DURATION = 200

@Loader =

  start: ->
    $(LOADER_SELECTOR).show().animate({opacity: 1}, TRANSITION_DURATION)

  done: ->
    $loader = $(LOADER_SELECTOR)
    $loader.animate { opacity: 0 }, TRANSITION_DURATION, ->
      $loader.hide()