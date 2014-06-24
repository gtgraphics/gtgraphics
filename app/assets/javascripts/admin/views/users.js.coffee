refreshGeneratePasswordCheckState = ->
  $passwordFields = $('#password_fields')
  if $('#user_generate_password_true').prop('checked')
    $passwordFields.find(':input').prop('disabled', true)
    $passwordFields.hide()
  else
    $passwordFields.find(':input').prop('disabled', false)
    $passwordFields.show()

$(document).ready ->
  # Generate Password Radio Buttons Behavior
  refreshGeneratePasswordCheckState()
  $(document).on 'change ifChanged', '#user_generate_password_true, #user_generate_password_false', ->
    $radioButton = $(@)
    refreshGeneratePasswordCheckState()