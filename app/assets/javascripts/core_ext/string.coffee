TRUE_VALUES = ['true', 't', '1']

String::blank = (trimmed = true) ->
  jQuery.trim(@) == ""

String::boolify = ->
  _.contains(TRUE_VALUES, @toLowerCase())

String::interpolate = (interpolations = {}) ->
  @replace /%\{(.*?)\}/g, (whole, key) ->
    camelizedKey = _(key).camelize()
    camelizedKey = camelizedKey.charAt(0).toLowerCase() + camelizedKey.slice(1)
    interpolations[camelizedKey] || interpolations[key] || ''