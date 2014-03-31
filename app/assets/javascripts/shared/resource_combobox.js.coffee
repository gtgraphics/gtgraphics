jQuery.prepare ->
  $('.resource-combobox').each ->
    $select = $(@)
  
    resourceUrl = $select.data('resourceUrl')
    formatterClass = $select.data('formatter')
    formatter = window[formatterClass] if formatterClass

    options = 
      minimumInputLength: 1
      ajax:
        url: resourceUrl
        dataType: 'json'
        data: (term, page) ->
          { query: term, page: page }
        results: (data, page) ->
          { results: data.records, more: data.more }
      initSelection: (element, callback) ->
        id = $(element).val()
        jQuery.get(resourceUrl, { id: id }, callback) unless id == ''
      escapeMarkup: (markup) ->
        markup

    if formatter
      _(options).extend
        formatResult: formatter.formatResult
        formatSelection: formatter.formatSelection

    $select.select2(options)