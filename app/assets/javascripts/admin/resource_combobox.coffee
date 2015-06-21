# Issue with Placeholders and allowClear:
# https://github.com/ivaynberg/select2/issues/1283

jQuery.prepare ->
  
  $('.resource-combobox').each ->
    $select = $(@)
    resourceName = $select.data('resource')
    
    options = 
      allowClear: $select.data('includeBlank') || false
      placeholder: $select.data('placeholder') || ' '
      multiple: $select.data('multiple') || false
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
          paginated = $select.data('paginated')
          if paginated
            results = data[resourceName]
            more = data.more
          else
            results = data
            more = false
          { results: results, more: more }
      initSelection: (element, callback) ->
        ids = $(element).val()
        if ids != ''
          url = $select.data('from')
          ids = ids.split(',')
          multiple = ids.length > 1
          ids = ids[0] unless multiple
          jQuery.get url, { id: ids }, (record) ->
            # if multiple
            #   callback(record[resourceName])
            # else
            #   callback(record)
            callback(record[resourceName] || record)  
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

    if $select.data('tokenSeparators')
      options.tokenSeparators = $select.data('tokenSeparators')

    if $select.data('allowNonExisting')
      options.createSearchChoice = (term, data) ->
        if $(data).filter(->
          @id.localeCompare(term) is 0
        ).length is 0
          { id: term }

    $select.select2(options)