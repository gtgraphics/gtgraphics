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

initRadios = ->
  $radios = $('#page_embeddable_attributes_external_true, #page_embeddable_attributes_external_false')
  $radios.each ->
    updateContainerVisibility($(@))
  $radios.click ->
    updateContainerVisibility($(@))


$(document).ready ->
  initRadios()

$(document).on 'changedEmbeddableType.pageEmbeddableManager', ->
  initRadios()
