$.fn.allImagesLoaded = (callback) ->
  $source = @
  $images = $('img', $source).add($source.filter('img'))
  totalCount = $images.length
  loadedCount = 0

  callbackWrapper = ->
    loadedCount++
    callback() if loadedCount == totalCount
    $source.trigger('imagesLoaded')
    console.debug "Image loaded: #{loadedCount}/#{totalCount}"

  $images.each ->
    $image = $(@)
    if $image.get(0).complete
      callbackWrapper()
    else
      $image.load(callbackWrapper)
      # $image.error(callbackWrapper)
