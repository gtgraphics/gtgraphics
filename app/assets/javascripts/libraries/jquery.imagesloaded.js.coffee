$.fn.allImagesLoaded = (callback) ->
  $source = @
  $images = $('img', $source).add($source.filter('img'))
  totalCount = $images.length
  loadedCount = 0
  $images.load ->
    loadedCount++
    callback() if loadedCount == totalCount
    $source.trigger('imagesLoaded')
  $images