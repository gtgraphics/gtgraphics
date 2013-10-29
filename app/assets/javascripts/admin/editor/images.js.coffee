updateContainerVisibility = ($radio) ->
  $destinationImageContainer = $('.editor_image_image_id')
  $destinationUrlContainer = $('.editor_image_url')

  checked = $radio.prop('checked')
  external = $radio.val() == 'true'
  if checked
    if external
      $destinationImageContainer.hide()
      $destinationUrlContainer.show()
    else
      $destinationImageContainer.show()
      $destinationUrlContainer.hide()

initRadios = ->
  $radios = $('#editor_image_external_true, #editor_image_external_false')
  $radios.each ->
    updateContainerVisibility($(@))
  $radios.click ->
    updateContainerVisibility($(@))

$(document).on 'show.bs.modal ajax:success', ->
  initRadios()