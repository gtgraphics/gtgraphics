jQuery.prepare ->
  $('.editor', @).editor(class: TextareaEditor)

  $('.simple-editor', @).editor
    class: TextareaEditor
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['orderedList', 'unorderedList']
    ]
