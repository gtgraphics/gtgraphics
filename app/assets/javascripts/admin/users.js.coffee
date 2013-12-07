refreshCheckState = ->
  $passwordFields = $('#password_fields')
  if $('#user_generate_password_true').is(':checked')
    $passwordFields.find(':input').prop('disabled', true)
    $passwordFields.hide()
  else
    $passwordFields.find(':input').prop('disabled', false)
    $passwordFields.show()

$(document).ready ->
  refreshCheckState()

  $(document).on 'click', '#user_generate_password_true, #user_generate_password_false', ->
    $radioButton = $(@)
    refreshCheckState()