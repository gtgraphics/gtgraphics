( ($) ->
  
  $.fn.addValidator = (validatorType, options = {}) ->
    $(@).each ->
      $input = $(@)

      validators = $input.data('validators') || []
      validators[attribute] ||= []

      validator = FormValidation.initValidator(validatorType, options)
      # validators[attribute].push(validator)
      
      $form.data('validators', validators)

  # $('.some-input').addValidator('name', 'presence')

  $.fn.addValidationError = (message) ->
    $input = $(@)
    FormValidation.addError($input, message)

  $.fn.removeValidationError = ->
    $input = $(@)
    FormValidation.removeError($input)

) jQuery