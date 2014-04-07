jQuery.prepare ->
  
  $('.resource-combobox').each ->
    $select = $(@)
  
    options = 
      ajax:
        url: ->
          $select.data('resourceUrl')
        dataType: 'json'
        data: (term, page) ->
          jQuery.extend({}, $select.data('params') || {}, { query: term, page: page })
        results: (data, page) ->
          { results: data.records, more: data.more }
      initSelection: (element, callback) ->
        id = $(element).val()
        unless id == ''
          resourceUrl = $select.data('resourceUrl')
          params = jQuery.extend({}, $select.data('params') || {}, { id: id })
          jQuery.get resourceUrl, params, (record) ->
            callback(record)
            $select.trigger('select2-init')
      escapeMarkup: (markup) ->
        markup
      formatResult: (result, container, query, escapeMarkup) ->
        formatterClass = $select.data('formatter')
        formatter = new window[formatterClass]() if formatterClass
        if formatter
          formatter.formatResult(result, container, query, escapeMarkup)
        else
          Select2.util.escapeMarkup(result.text)
      formatSelection: (data, container, escapeMarkup) ->
        formatterClass = $select.data('formatter')
        formatter = new window[formatterClass]() if formatterClass
        if formatter
          formatter.formatSelection(data, container, escapeMarkup)
        else
          Select2.util.escapeMarkup(result.text)

    $select.select2(options)