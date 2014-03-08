( ($) ->
  
  $.fn.editor = (options = {}) ->
    klass = options['class'] || Editor
    delete options['class']

    $(@).each ->
      $input = $(@)
      editor = new klass($input, options)
      $input.data('editor', editor)

) jQuery