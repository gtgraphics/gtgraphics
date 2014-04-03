jQuery.prepare ->
  
  $('.resource-combobox').each ->
    $select = $(@)
  
    resourceUrl = $select.data('resourceUrl')
    formatterClass = $select.data('formatter')
    additionalParams = $select.data('params') || {}
    formatter = new window[formatterClass]() if formatterClass

    options = 
      ajax:
        url: resourceUrl
        dataType: 'json'
        data: (term, page) ->
          _(additionalParams).defaults(query: term, page: page)
        results: (data, page) ->
          { results: data.records, more: data.more }
      initSelection: (element, callback) ->
        id = $(element).val()
        unless id == ''
          params = _(additionalParams).defaults(id: id)
          jQuery.get(resourceUrl, params, callback)
      escapeMarkup: (markup) ->
        markup

    if formatter
      _(options).extend
        formatResult: (result, container, query, escapeMarkup) ->
          formatter.formatResult(result, container, query, escapeMarkup)
        formatSelection: (data, container, escapeMarkup) ->
          formatter.formatSelection(data, container, escapeMarkup)

    $select.select2(options)