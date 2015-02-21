$(document).ready ->
   $('.img-emerging').each ->
    $image = $(@)
    $image.css(opacity: 0)
    $image.allImagesLoaded ->
      $image.transition(opacity: 1, duration: 500)
