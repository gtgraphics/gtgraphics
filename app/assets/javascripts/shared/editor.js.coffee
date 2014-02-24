jQuery.prepare ->
  $('.editor', @).editor()

  $('.simple-editor', @).editor
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['orderedList', 'unorderedList']
    ]