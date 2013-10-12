TRANSLATION_CONTAINER_SELECTOR = '.translations'
TRANSLATION_SELECT_SELECTOR = '.translation-select'

$(document).ready ->
  defaultLocale = $('html').attr('lang')
  currentLocale = defaultLocale
  languages = []
  locales = {}

  $(TRANSLATION_CONTAINER_SELECTOR).each ->
    $translation = $(@)
    language = $translation.data('language')
    locale = $translation.data('locale')
    languages.push(language)
    locales[language] = locale

  languages = languages.uniq().sort()

  $selects = $(TRANSLATION_SELECT_SELECTOR)
  if languages.length == 0
    $selects.hide()
  else
    $selects.show()

  # Set Select Options and Default Selection
  $.each languages, ->
    language = @
    locale = locales[language]
    $selects.each ->
      $select = $(@)
      $option = $('<option />', value: locale).text(language)
      $select.append($option).val(defaultLocale)

  # Display Layers for selected option, hide all others
  $(TRANSLATION_CONTAINER_SELECTOR).hide().filter(-> $(@).data('locale') == currentLocale).show()

  # Change other translation selects if a select changes
  $(document).on 'change', TRANSLATION_SELECT_SELECTOR, ->
    $select = $(@)
    currentLocale = $select.val()
    $(TRANSLATION_CONTAINER_SELECTOR).hide().filter(-> $(@).data('locale') == currentLocale).show()
    $(TRANSLATION_SELECT_SELECTOR).not($select).val($select.val())
