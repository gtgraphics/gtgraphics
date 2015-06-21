( ($) ->
  
  $.fn.editor = (options = {}) ->
    $(@).each ->
      $textarea = $(@)
      editor = $textarea.data('editor')
      unless editor
        editor = new Editor($textarea, options)
        editor.render()

) jQuery