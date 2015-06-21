class @TagsComboboxFormatter extends @ComboboxFormatter
  formatResult: (tag, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'tags-combobox-result clearfix')

    label = @markMatch(tag.id.toString(), query.term, escapeMarkup)
    $label = $('<div />', class: 'tags-combobox-label pull-left').appendTo($container)
    $label.html(label)

    $container

  formatSelection: (tag) ->
    tag.id
    