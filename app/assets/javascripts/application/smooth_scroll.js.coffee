DEFAULTS =
  duration: 500
  easing: 'swing'

$(document).on 'click', '[data-scroll]', (event) ->
  event.preventDefault()
  $link = $(@)
  if target instanceof String
    target = $link.data('scroll')
  else
    target = $link.data('target') || $link.attr('href')

  options = _(_($link.data()).pick(
    'scrollTarget', 'offsetTop', 'duration', 'easing'
  )).defaults(DEFAULTS)

  $(window).scrollTo(target, options)
  $link.blur()
