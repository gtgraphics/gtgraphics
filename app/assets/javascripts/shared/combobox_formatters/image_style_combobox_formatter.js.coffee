class @ImageStyleComboboxFormatter extends @ComboboxFormatter
  formatResult: (imageStyle, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'image-combobox-result clearfix')
    $thumbnail = $('<div />', class: 'image-combobox-thumbnail pull-left', alt: imageStyle.title).appendTo($container)
    $('<img />', src: imageStyle.thumbnailAssetUrl, class: 'img-circle').appendTo($thumbnail)
    
    $title = $('<div />', class: 'image-combobox-title').appendTo($container)
    title = @markMatch(imageStyle.title || imageStyle.humanDimensions, query.term, escapeMarkup)
    $title.html(title)

    $dimensions = $('<div />', class: 'image-combobox-dimensions text-muted').appendTo($container)
    $dimensions.html(imageStyle.humanDimensions) 

    $container

  formatSelection: (imageStyle) ->
    imageStyle.title || imageStyle.humanDimensions
    