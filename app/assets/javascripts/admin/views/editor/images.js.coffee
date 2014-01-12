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