class @ProjectComboboxFormatter extends @ComboboxFormatter
  formatResult: (project, container, query, escapeMarkup) ->
    $container = $('<div />', class: 'project-combobox-result clearfix')

    title = @markMatch(project.title, query.term, escapeMarkup)
    $title = $('<div />', class: 'project-combobox-title').appendTo($container)
    $title.html(title)

    if project.clientName
      client = @markMatch(project.clientName, query.term, escapeMarkup)
      $client = $('<div />', class: 'project-combobox-client text-muted').appendTo($container)
      $client.html(client)

    $container

  formatSelection: (project) ->
    project.title
    