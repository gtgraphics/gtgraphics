jQuery.prepare ->
  $('.combobox', @).select2()
  $('.tags', @).select2(multiple: true)
  $('.tokenizer', @).select2(tags: [], tokenSeparators: [','])