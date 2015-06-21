CONTAINER_SELECTOR = '.form-control-affixed'
INPUT_SELECTOR = "#{CONTAINER_SELECTOR} :input"

jQuery.prepare ->
  $(INPUT_SELECTOR, @).filter(':focus').addClass('focus')

$(document).on 'click', CONTAINER_SELECTOR, ->
  $(':input', @).focus()

$(document).on 'focus', INPUT_SELECTOR, ->
  $(@).closest(CONTAINER_SELECTOR).addClass('focus')

$(document).on 'blur', INPUT_SELECTOR, ->
  $(@).closest(CONTAINER_SELECTOR).removeClass('focus')
