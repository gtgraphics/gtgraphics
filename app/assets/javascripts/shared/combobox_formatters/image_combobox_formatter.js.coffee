class @ImageComboboxFormatter extends @ComboboxFormatter
  formatResult: (image, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'image-combobox-result clearfix')
    $thumbnail = $('<div />', class: 'image-combobox-thumbnail pull-left', alt: image.title).appendTo($container)
    $('<img />', src: image.thumbnailAssetUrl, class: 'img-circle').appendTo($thumbnail)

    $title = $('<div />', class: 'image-combobox-title').appendTo($container)
    title = @markMatch(image.title, query.term, escapeMarkup)
    $title.html(title)

    $dimensions = $('<div />', class: 'image-combobox-dimensions text-muted').appendTo($container)
    $dimensions.html(image.humanDimensions)

    $('<div />').text(image.format).appendTo($container)
    $container

  formatSelection: (image) ->
    image.title
    