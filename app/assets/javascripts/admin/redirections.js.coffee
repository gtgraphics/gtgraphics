updateContainerVisibility = ($radio) ->
  $destinationPageContainer = $('.page_embeddable_destination_page')
  $destinationUrlContainer = $('.page_embeddable_destination_url')

  checked = $radio.prop('checked')
  external = $radio.val() == 'true'
  if checked
    if external
      $destinationPageContainer.hide()
      $destinationUrlContainer.show()
    else
      $destinationPageContainer.show()
      $destinationUrlContainer.hide()

# TODO Trigger Events: Embeddable loaded and Translation Loaded

$(document).ready ->
  $radios = $('#page_embeddable_attributes_external_true, #page_embeddable_attributes_external_false')

  $radios.each ->
    updateContainerVisibility($(@))

  $radios.click ->
    updateContainerVisibility($(@))