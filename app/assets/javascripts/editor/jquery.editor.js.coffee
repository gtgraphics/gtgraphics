( ($) ->
  
  $.fn.editor = (options = {}) ->
    $(@).each ->
      $textarea = $(@)
      editor = $textarea.data('editor')
      unless editor
        editor = new TextareaEditor($textarea, options)
        editor.render()

) jQuery