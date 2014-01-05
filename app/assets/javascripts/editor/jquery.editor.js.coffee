( ($) ->
  
  $.fn.editor = (options = {}) ->
    @each ->
      $input = $(@)
      new Editor($input, options)

) jQuery