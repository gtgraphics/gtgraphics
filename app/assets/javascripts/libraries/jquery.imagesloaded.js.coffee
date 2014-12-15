$.fn.allImagesLoaded = (callback) ->
  $source = @
  $images = $('img', $source).add($source.filter('img'))
  totalCount = $images.length
  loadedCount = 0

  callbackWrapper = ->
    loadedCount++
    callback() if loadedCount == totalCount
    $source.trigger('imagesLoaded')

  $images.load(callbackWrapper)
  #$images.error(callbackWrapper)

  $images