$(document).ready ->
  $(':file:not([data-bfi-disabled])').each ->
    $file = $(@)
    console.log $file

    title = $file.attr('title') || $file.data('title')
    $file.removeAttr('title')

    $wrapper = $("<div />", class: 'btn btn-default btn-file', 'data-browse': 'files').insertAfter($file)
    $title = $("<span />", class: 'title').html(title)
    $wrapper.append($file)
    $wrapper.append($title)

# $(document).on 'click', '[data-browse="files"]', (event) ->
#   event.preventDefault()
#   $(@).find(':file').click()
