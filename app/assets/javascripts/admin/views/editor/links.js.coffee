updateContainerVisibility = ($radio) ->
  $destinationPageContainers = $('.editor_link_page_id, .editor_link_locale')
  $destinationUrlContainer = $('.editor_link_url')

  checked = $radio.prop('checked')
  external = $radio.val() == 'true'
  if checked
    if external
      $destinationPageContainers.hide()
      $destinationUrlContainer.show()
    else
      $destinationPageContainers.show()
      $destinationUrlContainer.hide()

initRadios = ->
  $radios = $('#editor_link_external_true, #editor_link_external_false')
  $radios.each ->
    updateContainerVisibility($(@))
  $radios.click ->
    updateContainerVisibility($(@))

$(document).on 'show.bs.modal ajax:success', ->
  initRadios()