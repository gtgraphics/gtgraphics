class @ClientComboboxFormatter extends @ComboboxFormatter
  formatResult: (client, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'client-combobox-result clearfix')

    title = @markMatch(client.id, query.term, escapeMarkup)
    $title = $('<div />', class: 'client-combobox-name pull-left').appendTo($container)
    $title.html(title)

    unless client.known
      $unknown = $('<div />', class: 'client-combobox-known text-muted pull-right').appendTo($container)
      $unknown.text(I18n.translate('views.admin.clients.create_unknown'))

    $container

  formatSelection: (client) ->
    client.id
    