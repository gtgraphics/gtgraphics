jQuery.prepare ->
  $('.editor', @).editor(class: RichTextEditor)

  $('.simple-editor', @).editor
    class: RichTextEditor
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['orderedList', 'unorderedList']
    ]
