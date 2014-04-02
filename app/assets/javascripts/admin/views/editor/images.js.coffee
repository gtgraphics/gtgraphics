RADIOS = '#editor_image_external_true, #editor_image_external_false'

refreshContainerStates = ($scope) ->
  $radios = $(RADIOS, $scope)
  $checkedRadio = $radios.filter(':checked')
  $internalFields = $('.editor-internal-image-fields')
  $externalFields = $('.editor-external-image-fields')
  if $checkedRadio.val() == 'true'
    $internalFields.hide()
    $externalFields.show()
  else
    $internalFields.show()
    $externalFields.hide()

jQuery.prepare ->
  refreshContainerStates(@)

$(document).on 'change ifChanged', RADIOS, ->
  refreshContainerStates()

$(document).on 'show.bs.modal ajax:success', ->
  refreshContainerStates()

$(document).on 'change', '#editor_image_image_id', ->
  $select = $(@)
  image = $select.select2('data')
  $('#editor_image_url').val(image.assetUrl)
  $('#editor_image_width').val(image.dimensions.width)
  $('#editor_image_height').val(image.dimensions.height)
  $('#editor_image_alternative_text').val(image.title)
