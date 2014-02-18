$(document).ready ->
  $.extend $.fn.select2.defaults,
    formatNoMatches: -> I18n.translate('select2.noMatches')
    formatInputTooShort: (input, min) -> I18n.translate('select2.inputTooShort', min: min, required: min - input.length)
    formatInputTooLong: (input, max) -> I18n.translate('select2.inputTooLong', max: max, required: input.length - max)
    formatSelectionTooBig: (limit) -> I18n.translate('select2.selectionTooBig', limit: limit)
    formatLoadMore: (page) -> I18n.translate('select2.loadMore', page: page)
    formatSearching: -> I18n.translate('select2.searching')

jQuery.prepare ->
  $('.combobox', @).select2()
  $('.tags', @).select2(multiple: true)
  $('.tokenizer', @).select2(tags: [], tokenSeparators: [','])
  $('.space-tokenizer', @).select2(tags: [], tokenSeparators: [' ', ','])