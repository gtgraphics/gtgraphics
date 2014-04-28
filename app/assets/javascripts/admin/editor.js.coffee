jQuery.prepare ->
  $('.editor', @).editor(class: TextareaEditor)

  $('.pictureless-editor', @).editor(class: TextareaEditor, controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['link', 'unlink'],
    'viewMode'
  ])

  $('.simple-editor', @).editor
    class: TextareaEditor
    controls: [
      ['bold', 'italic', 'underline', 'strikethrough'],
      ['orderedList', 'unorderedList']
    ]
