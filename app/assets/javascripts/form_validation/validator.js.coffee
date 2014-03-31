class @FormValidation.Validator
  constructor: (options = {}) ->
    @options = options

  validate: ($form, attribute, value) ->
    
    jQuery.when()
