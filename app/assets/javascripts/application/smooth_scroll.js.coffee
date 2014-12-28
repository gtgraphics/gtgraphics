DEFAULTS =
  duration: 1000
  easing: 'swing'

$(document).on 'click', '[data-scroll]', (event) ->
  event.preventDefault()
  $link = $(@)
  target = $link.data('target') || $link.attr('href')

  options = _(_($link.data()).pick(
    'scrollTarget', 'offsetTop', 'duration', 'easing'
  )).defaults(DEFAULTS)

  $(window).scrollTo(target, options)
  $link.blur()
