
# Cropper

normalizeInt = (value) ->
  value = parseInt(value)
  value = 0 if isNaN(value)
  value


class Cropper
  

$(document).ready ->
  $imageAsset = $('#image_asset')
  $imageAsset.load ->
    originalWidth = normalizeInt($imageAsset.data('originalWidth'))
    originalHeight = normalizeInt($imageAsset.data('originalHeight'))

    $cropX = $('.crop-x')
    $cropY = $('.crop-y')
    $cropWidth = $('.crop-width')
    $cropHeight = $('.crop-height')
    $resizeWidth = $('.resize-width')
    $resizeHeight = $('.resize-height')
    $preserveAspectRatio = $('.preserve-aspect-ratio')

    # Cropping

    cropX = normalizeInt($cropX.val())
    cropY = normalizeInt($cropY.val())
    cropWidth = normalizeInt($cropWidth.val())
    cropWidth = originalWidth if cropWidth == 0
    cropHeight = normalizeInt($cropHeight.val())
    cropHeight = originalHeight if cropHeight == 0

    updateFieldsInit = false
    updateFields = (coordinates) ->
      if updateFieldsInit
        $cropX.val(Math.round(coordinates.x))
        $cropY.val(Math.round(coordinates.y))
        $cropWidth.val(Math.round(coordinates.w))
        $cropHeight.val(Math.round(coordinates.h))
      updateFieldsInit = true

    $cropper = $.Jcrop($imageAsset.selector, {
      trueSize: [originalWidth, originalHeight]
      allowSelect: false
      onChange: updateFields
    })

    updateSelection = ->
      $cropper.setSelect([cropX, cropY, cropWidth + cropX, cropHeight + cropY])

    setCropAreaExplicitly = ->
      $cropX.val(cropX)
      $cropY.val(cropY)
      $cropWidth.val(cropWidth)
      $cropHeight.val(cropHeight)

    updateSelection()
    setCropAreaExplicitly()

    $('#image_style_preserve_crop_aspect_ratio').change ->
      if $(@).prop('checked')
        $cropper.setOptions(aspectRatio: cropWidth / cropHeight) 
      else
        $cropper.setOptions(aspectRatio: null) 

    $cropX.on 'textchange blur', ->
      cropX = normalizeInt($cropX.val())
      #updateSelection()
      setCropAreaExplicitly()

    $cropY.on 'textchange blur', ->
      cropY = normalizeInt($cropY.val())
      #updateSelection()
      setCropAreaExplicitly()

    $cropWidth.on 'textchange blur', ->
      cropWidth = normalizeInt($cropWidth.val())
      #updateSelection()
      setCropAreaExplicitly()

    $cropHeight.on 'textchange blur', ->
      cropHeight = normalizeInt($cropHeight.val())
      #updateSelection()
      setCropAreaExplicitly()

    # Scaling

    resizeWidth = normalizeInt($resizeWidth.val())
    resizeHeight = normalizeInt($resizeHeight.val())
    widthAspectRatio = resizeWidth / resizeHeight
    heightAspectRatio = resizeHeight / resizeWidth
    preserveAspectRatio = $preserveAspectRatio.prop('checked')

    refreshPreserveAspectRatioCheckState = ->
      preserveAspectRatio = $preserveAspectRatio.prop('checked')
      if preserveAspectRatio
        widthAspectRatio = resizeWidth / resizeHeight
        heightAspectRatio = resizeHeight / resizeWidth
      else
        widthAspectRatio = null
        heightAspectRatio = null

    refreshPreserveAspectRatioCheckState()
    $preserveAspectRatio.change(refreshPreserveAspectRatioCheckState)

    $resizeWidth.on 'textchange blur', ->
      resizeWidth = normalizeInt($resizeWidth.val())
      if preserveAspectRatio
        resizeHeight = Math.round(resizeWidth * heightAspectRatio)
        $resizeHeight.val(resizeHeight)

    $resizeHeight.on 'textchange blur', ->
      resizeHeight = normalizeInt($resizeHeight.val())
      if preserveAspectRatio
        resizeWidth = Math.round(resizeHeight * widthAspectRatio)
        $resizeWidth.val(resizeWidth)

    # $resizeWidth.attr('max', cropWidth)
    # $resizeHeight.attr('max', cropHeight)

    $cropWidth.on 'textchange blur', ->
      

    origResizeHeight = resizeHeight

    $cropHeight.on 'textchange blur', ->
      resizeHeightRatio = cropHeight / origResizeHeight
      resizeHeight = Math.round(resizeHeightRatio * origResizeHeight)
      $resizeHeight.val(resizeHeight)