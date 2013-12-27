updateContainerVisibility = ($radio) ->
  $destinationImageContainers = $('.editor_image_image_id, .editor_image_image_style')
  $destinationUrlContainer = $('.editor_image_url')

  checked = $radio.prop('checked')
  external = $radio.val() == 'true'
  if checked
    if external
      $destinationImageContainers.hide()
      $destinationUrlContainer.show()
    else
      $destinationImageContainers.show()
      $destinationUrlContainer.hide()

initRadios = ->
  $radios = $('#editor_image_external_true, #editor_image_external_false')
  $radios.each ->
    updateContainerVisibility($(@))
  $radios.click ->
    updateContainerVisibility($(@))

$(document).on 'show.bs.modal ajax:success', ->
  initRadios()

$(document).on 'change', '#editor_image_image_id, #editor_image_image_style', ->
  $style = $('#editor_image_image_style')
  $image = $('#editor_image_image_id')
  $width = $('#editor_image_width')
  $height = $('#editor_image_height')

  id = $image.val()
  style = $style.val()

  if id isnt ''
    jQuery.getJSON "/admin/images/#{id}/dimensions.json", { style: style }, (dimensions) ->
      $width.val(dimensions.width)
      $height.val(dimensions.height)


# Cropper

normalizeInt = (value) ->
  value = parseInt(value)
  value = 0 if isNaN(value)
  value

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

    $cropX.on 'textchange blur', ->
      cropX = normalizeInt($cropX.val())
      updateSelection()
      setCropAreaExplicitly()

    $cropY.on 'textchange blur', ->
      cropY = normalizeInt($cropY.val())
      updateSelection()
      setCropAreaExplicitly()

    $cropWidth.on 'textchange blur', ->
      cropWidth = normalizeInt($cropWidth.val())
      updateSelection()
      setCropAreaExplicitly()

    $cropHeight.on 'textchange blur', ->
      cropHeight = normalizeInt($cropHeight.val())
      updateSelection()
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

    $cropWidth.on 'textchange blur', ->
      if preserveAspectRatio
        resizeCropWidthRatio = resizeWidth / cropWidth
        resizeCropHeightRatio = resizeHeight / cropHeight
        console.log resizeCropWidthRatio
        console.log resizeCropHeightRatio

    $cropHeight.on 'textchange blur', ->
