@ImageComboboxFormatter =

  formatResult: (image) ->
    $container = $('<div />', class: 'image-result clearfix')
    $thumbnail = $('<div />', class: 'image-thumbnail pull-left', alt: image.title).appendTo($container)
    $('<img />', src: image.thumbnailUrl, class: 'img-circle', width: 35, height: 35).appendTo($thumbnail)
    $('<div />', class: 'image-title').text(image.title).appendTo($container)
    $('<div />').text(image.format).appendTo($container)
    $container

  formatSelection: (image) ->
    image.title
    