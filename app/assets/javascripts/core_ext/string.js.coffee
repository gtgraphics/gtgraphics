TRUE_VALUES = ['true', 't', '1']

String::blank = (trimmed = true) ->
  jQuery.trim(@) == ""

String::boolify = ->
  _.contains(TRUE_VALUES, @toLowerCase())

String::interpolate = (interpolations = {}) ->
  @replace /%\{(.*?)\}/g, (whole, expression) ->
    interpolations[expression] || ''
