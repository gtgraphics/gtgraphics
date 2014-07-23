jQuery.prepare ->
  $('.editor, [data-behavior="editor"]', @).editor()

  $('.pictureless-editor', @).editor controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['link', 'unlink'],
    'viewMode'
  ]

  $('.simple-editor', @).editor controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['orderedList', 'unorderedList']
  ]

  $('.image-editor, .attachment-editor', @).editor controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['link', 'unlink'],
    'viewMode'
  ]