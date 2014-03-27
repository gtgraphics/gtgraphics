RADIOS = '#editor_link_external_true, #editor_link_external_false'

refreshContainerStates = ($scope) ->
  $radios = $(RADIOS, $scope)
  $checkedRadio = $radios.filter(':checked')
  $internalFields = $('.editor-internal-link-fields')
  $externalFields = $('.editor-external-link-fields')
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