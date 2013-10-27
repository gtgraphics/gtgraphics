updateContainerVisibility = ($radio) ->
  $destinationPageContainer = $('.editor_link_page_id')
  $destinationUrlContainer = $('.editor_link_url')

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
  $radios = $('#editor_link_external_true, #editor_link_external_false')
  $radios.each ->
    updateContainerVisibility($(@))
  $radios.click ->
    updateContainerVisibility($(@))

$(document).on 'show.bs.modal ajax:success', ->
  initRadios()