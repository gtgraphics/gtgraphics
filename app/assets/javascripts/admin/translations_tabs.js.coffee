queryRemoveButtonState = ($tabs) ->
  disabled = $tabs.find('.translation-tab.translation-available').length <= 1
  $tabs.find('.remove-translation').prop('disabled', disabled)

#queryAddSelectButtonState = ($tabs) ->
#  hidden = $tabs.find('.add-translation').length == $tabs.find('.translation-tab').length
#  $button = $tabs.find('.add-translation-select')
#  if hidden
#    $button.hide()
#  else
#    $button.show()

queryAddButtonStates = ($tabs) ->
  $addableItems = $tabs.find('.add-translation')
  $addableItems.each ->
    $item = $(@).closest('li')
    if translationAdded($tabs, $item.data('locale'))
      $item.addClass('disabled')
    else
      $item.removeClass('disabled')

queryState = ($tabs) ->
  queryRemoveButtonState($tabs)
  queryAddButtonStates($tabs)
  #queryAddSelectButtonState($tabs)

translationAdded = ($tabs, locale) ->
  added = false
  $tabs.find('.translation-tab.translation-available').each ->
    if $(@).data('locale') == locale
      added = true
      return false
  added

initAvailableTabs = ($tabs) ->
  $target = $($tabs.data('target'))

  definedLocales = []
  $target.find('.tab-pane[data-locale]').each ->
    $tabPane = $(@)
    definedLocales.push($tabPane.data('locale'))

  $tabs.find('.translation-tab').each ->
    $tab = $(@)
    locale = $tab.data('locale')
    if jQuery.inArray(locale, definedLocales) >= 0
      $tab.show()
      $tab.addClass('translation-available')
    else
      $tab.hide()
      $tab.removeClass('translation-available')

createTranslation = ($tabs, locale) ->
  $target = $($tabs.data('target'))
  $tabPane = $target.find(".tab-pane[data-locale='#{locale}']")
  translationLoaded = $tabPane.length > 0
  if translationLoaded
    $tabPane.show()
    $tabPane.find("input[name='_destroy']").val(0)
    # TODO add existing _destroy hidden field in pane to false!!!
    $newTabLink = $tabs.find(".translation-tab[data-locale='#{locale}'] a")
    $newTabLink.tab('show')
  else
    # Fixme - Remove Temp Fix
    $tabPane = $('<div />', id: locale, class: 'tab-pane', 'data-locale': locale)
    $tabPane.appendTo($target)

    # TODO: Add HTML via AJAX or re-show already loaded container
    console.log 'load via ajax......'

    $newTabLink = $tabs.find(".translation-tab[data-locale='#{locale}'] a")
    $newTabLink.tab('show')

$(document).ready ->
  $('#translations_tabs').each ->
    $tabs = $(@)
    initAvailableTabs($tabs)
    queryState($tabs)

    # Tab Actions
    $tabs.find('.translation-tab a').click (event) ->
      event.preventDefault()
      $(@).tab('show')

    # Remove Translation
    $tabs.on 'click', '.remove-translation', (event) ->
      event.preventDefault()
      event.stopPropagation()

      $link = $(@)
      $tab = $link.closest('.translation-tab')
      if $tab.hasClass('active')
        $tab.siblings('.translation-tab').first().find('a').tab('show') 
      $tab.hide().removeClass('translation-available')

      $link.tooltip('hide') # dirty fix

      queryState($tabs)

    # Add Translation
    $tabs.find('.add-translation').click (event) ->
      event.preventDefault()
      $link = $(@)
      unless $link.closest('li').hasClass('disabled')
        locale = $link.data('locale')
        $tab = $tabs.find(".translation-tab[data-locale='#{locale}']")
        $tab.show().addClass('translation-available')

        createTranslation($tabs, locale)

        queryState($tabs)