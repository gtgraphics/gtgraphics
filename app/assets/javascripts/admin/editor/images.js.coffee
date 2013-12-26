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
    $x = $('#image_crop_x')
    $y = $('#image_crop_y')
    $width = $('#image_crop_width')
    $height = $('#image_crop_height')

    updateFieldsInit = false

    updateFields = (coordinates) ->
      if updateFieldsInit
        $x.val(Math.round(coordinates.x))
        $y.val(Math.round(coordinates.y))
        $width.val(Math.round(coordinates.w))
        $height.val(Math.round(coordinates.h))
      updateFieldsInit = true

    originalWidth = normalizeInt($imageAsset.data('originalWidth'))
    originalHeight = normalizeInt($imageAsset.data('originalHeight'))

    currentX = normalizeInt($x.val())
    currentY = normalizeInt($y.val())
    currentWidth = normalizeInt($width.val())
    currentWidth = originalWidth if currentWidth == 0
    currentHeight = normalizeInt($height.val())
    currentHeight = originalHeight if currentHeight == 0

    $cropper = $.Jcrop($imageAsset.selector, {
      trueSize: [originalWidth, originalHeight]
      allowSelect: false
      onChange: updateFields
    })

    updateSelection = ->
      $cropper.setSelect([currentX, currentY, currentWidth + currentX, currentHeight + currentY])

    setCropRectExplicitly = ->
      $x.val(currentX)
      $y.val(currentY)
      $width.val(currentWidth)
      $height.val(currentHeight)

    updateSelection()
    setCropRectExplicitly()

    $x.on 'textchange blur', ->
      currentX = normalizeInt($x.val())
      updateSelection()
      setCropRectExplicitly()

    $y.on 'textchange blur', ->
      currentY = normalizeInt($y.val())
      updateSelection()
      setCropRectExplicitly()

    $width.on 'textchange blur', ->
      currentWidth = normalizeInt($width.val())
      updateSelection()
      setCropRectExplicitly()

    $height.on 'textchange blur', ->
      currentHeight = normalizeInt($height.val())
      updateSelection()
      setCropRectExplicitly()

    @cropper = $cropper