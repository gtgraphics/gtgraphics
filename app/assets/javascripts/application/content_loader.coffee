$(document).ready ->
  $('[data-load="content"]').each ->
    $container = $(@)
    url = $container.data('url')
    $container.load(url)
