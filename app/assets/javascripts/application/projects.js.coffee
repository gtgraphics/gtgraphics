$(document).ready ->
  $thumbnails = $('.project-thumbnail')
  if $thumbnails.length
    Loader.start()
    $thumbnails.allImagesLoaded ->
      Loader.done()
