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
    $button = @getChangeLocaleButton(locale)
    $button.trigger('changingLocale.translationManager', locale)
    @selectedLocale = locale
    @showPanes(locale)
    @refreshButtonStates()
    $button.trigger('changedLocale.translationManager', locale)
    true

  addLocale: (locale) ->
    # TODO Reset _destroy Form Field
    return false if @translatedLocales.include(locale)
    $button = @getAddLocaleButton(locale)
    $button.trigger('addingLocale.translationManager', locale)
    @translatedLocales.push(locale)
    $localePanes = @getLocalePanes(locale, true)
    if $localePanes.any()
      $localePanes.removeClass('removed')
      $button.trigger('addedLocale.translationManager', locale)
      @changeLocale(locale)
      @refreshButtonStates()
    else
      @loadPane locale, =>
        $button.trigger('addedLocale.translationManager', locale)
        @changeLocale(locale)
        @refreshButtonStates()
    true

  removeLocale: (locale) ->
    # TODO Set _destroy Form Field
    return false unless @translatedLocales.include(locale)
    $button = @getRemoveLocaleButton(locale)
    $button.trigger('removingLocale.translationManager', locale)
    @translatedLocales.remove(locale)
    @getLocalePanes(locale).addClass('removed')
    @refreshButtonStates()
    $button.trigger('removedLocale.translationManager', locale)
    @changeLocale(@getNeighborLocale(locale)) if @selectedLocale == locale
    true

  # State refreshers

  queryInitialState: ->
    @availableLocales = @getAddLocaleButtons().map(-> $(@).data('locale')).toArray()
    @translatedLocales = @getPanes().map(-> $(@).data('locale')).toArray().uniq()
    @setInitialLocale()

  setInitialLocale: ->
    _this = @
    localeWithErrors = null
    jQuery.each @translatedLocales, ->
      locale = @toString()
      $panes = _this.getLocalePanes(locale)
      if $('.form-group', $panes).any('.has-error')
        localeWithErrors = locale
        return false
    initialLocale = localeWithErrors || I18n.locale
    @changeLocale(initialLocale)

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

  loadPane: (locale, callback) ->
    jQuery.get @url, { translated_locale: locale }, (html) =>
      $html = $(html).appendTo(@container.find('.tab-content')).prepare()
      callback.call($html) if callback

  # Helpers
  getNeighborLocale: ->
    index = @translatedLocales.index(@selectedLocale)
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
      translationManager = new TranslationManager($container)
      $container.data('translationManager', translationManager)
    .on 'removedLocale.translationManager', ->
      $('.tooltip', @).remove()
