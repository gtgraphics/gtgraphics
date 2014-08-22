class @ComboboxFormatter
  formatResult: (record, container, query, escapeMarkup) ->
    console.error 'formatResult() not implemented'

  formatSelection: (record, container, escapeMarkup) ->
    console.error 'formatSelection() not implemented'

  markMatch: (text, term, escapeMarkup) ->
    markup = []
    Select2.util.markMatch(text, term, markup, escapeMarkup)
    markup.join('')