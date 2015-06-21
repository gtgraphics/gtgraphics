class @ImageStyleComboboxFormatter extends @ComboboxFormatter
  formatResult: (imageStyle, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'image')
    $thumbnail = $('<div />', class: 'preview', alt: imageStyle.title).appendTo($container)
    $('<img />', src: imageStyle.thumbnailAssetUrl, class: 'img-circle', width: 45, height: 45).appendTo($thumbnail)
    
    $title = $('<div />', class: 'title').appendTo($container)
    title = @markMatch(imageStyle.title || imageStyle.humanDimensions, query.term, escapeMarkup)
    $title.html(title)

    $dimensions = $('<div />', class: 'detail').appendTo($container)
    $dimensions.html(imageStyle.humanDimensions) 

    $container

  formatSelection: (imageStyle) ->
    imageStyle.title || imageStyle.humanDimensions
    