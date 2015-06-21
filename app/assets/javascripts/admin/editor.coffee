REGION_TYPES =
  full: null,
  simple: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['orderedList', 'unorderedList']
  ]
  image: [
    ['image']
  ]
  linked_image: [
    ['image'], ['link', 'unlink']
  ]

jQuery.prepare ->
  $(".editor, [data-behavior='editor']:not([data-type])", @).editor()

  # Region Editors

  _(REGION_TYPES).each (controls, regionType) =>
    if controls
      options = { controls: controls }
    else
      options = {}
    $("[data-behavior='editor'][data-type='#{regionType}']", @).editor(options)

  # Special Editors

  $('.pictureless-editor', @).editor controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['alignLeft', 'alignCenter', 'alignRight', 'alignJustify'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['link', 'unlink'],
    'viewMode'
  ]

  $('.caption-editor', @).editor controls: [
    ['bold', 'italic', 'underline', 'strikethrough'],
    ['orderedList', 'unorderedList', 'indent', 'outdent'],
    ['link', 'unlink'],
    'viewMode'
  ]
