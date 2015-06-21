$(document).ready ->
  $('.img-emerging, .region-image img, .region-linked-image img').each ->
    $image = $(@).css(opacity: 0)
    $image.allImagesLoaded ->
      $image.transition(opacity: 1, duration: 500)

  $('.img-unveiling').unveil 100, ->
    Loader.start()
    $(@).load ->
      $(@).transition(opacity: 1, duration: 500)
      Loader.done()
