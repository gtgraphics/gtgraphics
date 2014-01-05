
class @TranslationManager
  constructor: ($container) ->
    @container = $container
    @queryInitialState()
    @refreshButtonStates()
    @applyEvents()
    @url = @container.data('url')

  # Events

  applyEvents: ->
    @applyChangeLocaleEvent()
    @applyAddLocaleEvent()
    @applyRemoveLocaleEvent()

  applyChangeLocaleEvent: ->
    _this = @
    @getChangeLocaleButtons().on 'click', (event) ->
      event.preventDefault()
      $link = $(@)
      unless $link.hasClass('disabled') and $link.prop('disabled')
        locale = $link.data('locale')
        _this.changeLocale(locale)
      true

  applyAddLocaleEvent: ->
    _this = @
    @container.on 'click', '.add-locale', (event) ->
      event.preventDefault()
      $link = $(@)
      unless $link.hasClass('disabled') and $link.prop('disabled')
        locale = $link.data('locale')
        _this.addLocale(locale)
      true

  applyRemoveLocaleEvent: ->
    _this = @
    @container.on 'click', '.remove-locale', (event) ->
      event.preventDefault()
      $link = $(@)
      unless $link.hasClass('disabled') and $link.prop('disabled')
        locale = $link.data('locale')
        _this.removeLocale(locale)
      true     

  # Primary Methods

  changeLocale: (locale) ->
    return false if @selectedLocale and @selectedLocale == locale
    return false unless @translatedLocales.include(locale)
    @selectedLocale = locale
    @showPanes(locale)
    @refreshButtonStates()
    @getChangeLocaleButton(locale).trigger('changedLocale.translationManager', locale)
    console.debug "changed locale: #{locale}"
    true

  addLocale: (locale) ->
    return false if @translatedLocales.include(locale)
    @translatedLocales.push(locale)
    @getLocalePanes(locale, true).removeClass('removed')
    @refreshButtonStates()
    @getAddLocaleButton(locale).trigger('addedLocale.translationManager', locale)
    console.debug "added locale: #{locale}"
    @changeLocale(locale)
    true

  removeLocale: (locale) ->
    return false unless @translatedLocales.include(locale)
    @translatedLocales.remove(locale)
    @getLocalePanes(locale).addClass('removed')
    @refreshButtonStates()
    @getRemoveLocaleButton(locale).trigger('removedLocale.translationManager', locale)
    console.debug "removed locale: #{locale}"
    @changeLocale(@getNeighborLocale(locale)) if @selectedLocale == locale
    true

  # State refreshers

  queryInitialState: ->
    # TODO Improve?
    @availableLocales = @getAddLocaleButtons().map(-> $(@).data('locale')).toArray()
    @translatedLocales = @getPanes().map(-> $(@).data('locale')).toArray().uniq()
    @changeLocale(I18n.locale)

  refreshButtonStates: ->
    @refreshChangeLocaleButtonStates()
    @refreshAddLocaleButtonStates()
    @refreshRemoveLocaleButtonStates()

  refreshChangeLocaleButtonStates: ->
    _this = @
    @getChangeLocaleButtons().each ->
      $link = $(@)
      locale = $link.data('locale')

      # Added/removed: Display or hide
      hidden = !_this.translatedLocales.include(locale)
      _this.hideChangeLocaleButton(locale, hidden)

      # Changed: Active or inactive
      activated = _this.selectedLocale == locale
      _this.activateChangeLocaleButton(locale, activated)

  refreshAddLocaleButtonStates: ->
    _this = @
    @getAddLocaleButtons().each ->
      $button = $(@)
      locale = $button.data('locale')
      _this.disableAddLocaleButton(locale, _this.translatedLocales.include(locale))

  refreshRemoveLocaleButtonStates: ->
    _this = @
    @getRemoveLocaleButtons().each ->
      $button = $(@)
      locale = $button.data('locale')
      _this.disableRemoveLocaleButton(locale, _this.translatedLocales.length <= 1)

  # Button getters

  getChangeLocaleButton: (locale) ->
    @getChangeLocaleButtons().filter(localeFilter(locale))

  getChangeLocaleButtons: ->
    $('.change-locale', @container)

  getRemoveLocaleButton: (locale) ->
    @getRemoveLocaleButtons().filter(localeFilter(locale))

  getRemoveLocaleButtons: ->
    $('.remove-locale', @container)

  getAddLocaleButton: (locale) ->
    @getAddLocaleButtons().filter(localeFilter(locale))

  getAddLocaleButtons: ->
    $('.add-locale', @container)

  getDestroyTranslationInputs: (locale) ->
    @getLocalePanes(locale).find('.destroy-translation')

  # Button actions

  activateChangeLocaleButton: (locale, activated = true) ->
    $listItem = @getChangeLocaleButton(locale).closest('li')
    if activated
      $listItem.addClass('active')
    else
      $listItem.removeClass('active')

  disableAddLocaleButton: (locale, disabled = true) ->
    $listItem = @getAddLocaleButton(locale).closest('li')
    if disabled
      $listItem.addClass('disabled')
    else
      $listItem.removeClass('disabled')

  disableRemoveLocaleButton: (locale, disabled = true) ->
    @getRemoveLocaleButton(locale).prop('disabled', disabled)

  hideChangeLocaleButton: (locale, hidden = true) ->
    $listItem = @getChangeLocaleButton(locale).closest('li')
    if hidden
      $listItem.hide()
    else
      $listItem.show()

  # Pane getters

  getPanes: (includeRemoved = false) ->
    $panes = $('.tab-content', @container).find('.tab-pane')
    $panes = $panes.not('.removed') unless includeRemoved
    $panes

  getLocalePanes: (locale, includeRemoved = false) ->
    @getPanes(includeRemoved).filter(localeFilter(locale))
   

  showPanes: (locale) ->
    @getPanes(true).removeClass('active')
    @getLocalePanes(locale, true).addClass('active')

  loadPane: (locale) ->

  # Helpers
  getNeighborLocale: ->
    index = jQuery.inArray(@selectedLocale, @translatedLocales)
    locale = @translatedLocales[index + 1]
    locale ||= @translatedLocales[index - 1]
    locale

  localeFilter = (locale) ->
    jQuery.error 'locale not defined' if !locale or locale == ''
    "[data-locale='#{locale}']"

$(document).ready ->
  $('.translation-manager')
    .each ->
      $container = $(@)
      $container.data('translationManager', new TranslationManager($container))
    .on 'removedLocale.translationManager', ->
      $('.tooltip', @).remove()
