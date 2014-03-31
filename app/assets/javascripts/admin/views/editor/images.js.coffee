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