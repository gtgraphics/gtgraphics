TRUE_VALUES = ['true', '1']

String::boolify = ->
  $.inArray(@toLowerCase(), TRUE_VALUES) >= 0

String::capitalize = ->
  @charAt(0).toUpperCase() + @slice(1);

String::blank = (trimmed = true) ->
  if trimmed
    str = $.trim(@)
  else
    str = @
  str == ""