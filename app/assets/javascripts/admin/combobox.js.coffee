$.extend jQuery.fn.select2.defaults,
  formatNoMatches: -> I18n.translate('javascript.select2.no_matches')
  formatInputTooShort: (input, min) -> I18n.translate('javascript.select2.input_too_short', min: min, required: min - input.length)
  formatInputTooLong: (input, max) -> I18n.translate('javascript.select2.input_too_long', max: max, required: input.length - max)
  formatSelectionTooBig: (limit) -> I18n.translate('javascript.select2.selection_too_big', limit: limit)
  formatLoadMore: (page) -> I18n.translate('javascript.select2.load_more', page: page)
  formatSearching: -> I18n.translate('javascript.select2.searching')

jQuery.prepare ->
  unless Modernizr.touch
    $('.combobox', @).each ->
      $input = $(@)
      $input.select2
        allowClear: $input.data('includeBlank')

    $('.tokenizer, [data-behavior="tokenizer"]', @).select2(tags: [], tokenSeparators: [','])

    $('.space-tokenizer', @).select2(tags: [], tokenSeparators: [' ', ','])

