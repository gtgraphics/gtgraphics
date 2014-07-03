updateContainerVisibility = ($radio, $scope) ->
  $destinationPageContainer = $('.page_embeddable_destination_page, .page_redirection_destination_page', $scope)
  $destinationUrlContainer = $('.page_embeddable_destination_url, .page_redirection_destination_url', $scope)

  checked = $radio.prop('checked')
  external = $radio.val() == 'true'
  if checked
    if external
      $destinationPageContainer.hide()
      $destinationUrlContainer.show()
    else
      $destinationPageContainer.show()
      $destinationUrlContainer.hide()

initRadios = ($scope) ->
  $radios = $('#page_embeddable_attributes_external_true, #page_redirection_external_true, #page_embeddable_attributes_external_false, #page_redirection_external_false', $scope)
  console.log $radios
  $radios.each ->
    updateContainerVisibility($(@), $scope)
  $radios.click ->
    updateContainerVisibility($(@), $scope)

jQuery.prepare ->
  initRadios(@)
