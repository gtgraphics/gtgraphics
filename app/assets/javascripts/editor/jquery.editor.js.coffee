( ($) ->
  
  $.fn.editor = (options = {}) ->
    klass = options['class'] || Editor
    delete options['class']
    @each ->
      editor = new klass($(@), options)
      $(@).data('editor', editor)

) jQuery