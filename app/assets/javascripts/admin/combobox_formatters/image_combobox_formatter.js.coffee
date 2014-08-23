class @ImageComboboxFormatter extends @ComboboxFormatter
  formatResult: (image, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'image')
    $thumbnail = $('<div />', class: 'preview', alt: image.title).appendTo($container)
    $('<img />', src: image.thumbnailAssetUrl, class: 'img-circle', width: 45, height: 45, alt: image.title).appendTo($thumbnail)

    $title = $('<div />', class: 'title').appendTo($container)
    title = @markMatch(image.title, query.term, escapeMarkup)
    $title.html(title)

    $dimensions = $('<div />', class: 'detail').appendTo($container)
    $dimensions.html(image.humanDimensions)

    $('<div />').text(image.format).appendTo($container)
    $container

  formatSelection: (image) ->
    image.title
    