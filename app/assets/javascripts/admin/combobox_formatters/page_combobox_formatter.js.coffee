class @PageComboboxFormatter extends @ComboboxFormatter
  formatResult: (page, container, query, escapeMarkup) ->
    css = "page-combobox-result"
    css += " depth-#{page.depth}" # if query.term == ''
    $container = $('<div />', class: css)
    $title = $('<div />', class: 'page-combobox-title').appendTo($container)
    $title.html(@markMatch(page.title, query.term, escapeMarkup))
    if page.path != ''
      $info = $('<div />', class: 'page-combobox-info').appendTo($container)
      $info.html(@markMatch(page.path, query.term, escapeMarkup))
    $('<div />').text(page.format).appendTo($container)
    $container

  formatSelection: (page) ->
    page.title
    