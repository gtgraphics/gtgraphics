( ($) ->
  
  $.fn.editor = (options = {}) ->
    $(@).each ->
      editor = new TextareaEditor($(@), options)
      editor.render()

) jQuery