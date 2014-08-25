$(document).ready ->
  $search = $('#search')

  $search.select2
    placeholder: I18n.translate('helpers.prompts.search')
    minimumInputLength: 2,
    ajax:
      url: $search.data('from')
      dataType: 'json'
      data: (term, page) ->
        { query: term }
      results: (data, page) ->
        results = data
        { results: results, more: false }