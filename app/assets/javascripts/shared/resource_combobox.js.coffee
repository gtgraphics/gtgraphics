# Issue with Placeholders and allowClear:
# https://github.com/ivaynberg/select2/issues/1283

jQuery.prepare ->
  
  $('.resource-combobox').each ->
    $select = $(@)
    options = 
      allowClear: $select.data('includeBlank') || false
      placeholder: $select.data('placeholder') || ' '
      ajax:
        url: ->
          $select.data('from')
        dataType: 'json'
        data: (term, page) ->
          paginated = $select.data('paginated')
          if paginated
            { query: term, page: page }
          else
            { query: term }
        results: (data, page) ->
          resourceName = $select.data('resource')
          paginated = $select.data('paginated')
          if paginated
            results = data[resourceName]
            more = data.more
          else
            results = data
            more = false
          { results: results, more: more }
      initSelection: (element, callback) ->
        id = $(element).val()
        unless id == ''
          url = $select.data('from')
          jQuery.get url, { id: id }, (record) ->
            callback(record)
            $select.trigger('select2-init')
      escapeMarkup: (markup) ->
        markup
      formatResult: (result, container, query, escapeMarkup) ->
        formatterClassName = $select.data('formatter')
        if formatterClassName
          formatterClass = window[formatterClassName]
          jQuery.error "#{formatterClassName} not found" unless formatterClass
          formatter = new formatterClass() 
        if formatter
          formatter.formatResult(result, container, query, escapeMarkup)
        else
          Select2.util.escapeMarkup(result.text)
      formatSelection: (data, container, escapeMarkup) ->
        formatterClassName = $select.data('formatter')
        if formatterClassName
          formatterClass = window[formatterClassName]
          jQuery.error "#{formatterClassName} not found" unless formatterClass
          formatter = new formatterClass() 
        if formatter
          formatter.formatSelection(data, container, escapeMarkup)
        else
          Select2.util.escapeMarkup(result.text)

    $select.select2(options)