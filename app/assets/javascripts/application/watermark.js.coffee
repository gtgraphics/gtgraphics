alignWatermark = ->
  $lightbox = $('#lightbox')
  return unless $lightbox.length

  $lightboxImage = $('.lightbox-image', $lightbox)
  containerWidth = $lightboxImage.width()
  containerHeight = $lightboxImage.height()
  containerAspectRatio = containerWidth / containerHeight

  $image = $('img', $lightboxImage)
  imageWidth = $image.attr('width')
  imageHeight = $image.attr('height')
  imageAspectRatio = imageWidth / imageHeight

  if containerAspectRatio > imageAspectRatio
    ratio = containerHeight / imageHeight
  else
    ratio = containerWidth / imageWidth

  containerImageWidth = Math.round(imageWidth * ratio)
  containerImageHeight = Math.round(imageHeight * ratio)

  right = (containerWidth - containerImageWidth) / 2
  right = 0 if right < 0
  bottom = (containerHeight - containerImageHeight) / 2
  bottom = 0 if bottom < 0

  $watermark = $('.lightbox-watermark', $lightbox)
  $watermark.css(right: right, bottom: bottom)

$(document).ready ->
  $('.lightbox-image-container').allImagesLoaded ->
    alignWatermark()

$(window).resize ->
  alignWatermark()
