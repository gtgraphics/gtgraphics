TRUE_VALUES = ['true', 't', '1']

String::blank = (trimmed = true) ->
  jQuery.trim(@) == ""

String::boolify = ->
  TRUE_VALUES.include(@toLowerCase())

String::camelize = ->
  pieces = @split(/[\W_-]/)
  jQuery.map(pieces, (piece) -> piece.capitalize()).join("")

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1);

String::dasherize = ->
  @replace("_", "-")

String::interpolate = (interpolations = {}) ->
  @replace /%\{(.*?)\}/g, (whole, expression) ->
    interpolations[expression] || ""

String::underscore = ->
  @replace(/[\W]/g, "").replace /[A-Z]/g, (match) ->
    "_#{match.toLowerCase()}"