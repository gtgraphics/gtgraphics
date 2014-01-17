class @TranslationManager
  constructor: ($container) ->
    @container = $container
    @queryInitialState()
    @refreshButtonStates()
    @applyEvents()
    @url = @container.data('url')
    @dataType = @container.data('dataType') || 'html'

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
    return false unless _.contains(@translatedLocales, locale)
    $button = @getChangeLocaleButton(locale)
    $button.trigger('changingLocale.translationManager', locale)
    @selectedLocale = locale
    @showSelectedLocalePanes()
    @refreshButtonStates()
    $button.trigger('changedLocale.translationManager', locale)
    true

  showSelectedLocalePanes: ->
    @showPanes(@selectedLocale)

  addLocale: (locale, callback) ->
    return false if _.contains(@translatedLocales, locale)
    $button = @getAddLocaleButton(locale)
    $button.trigger('addingLocale.translationManager', locale)

    addedLocaleCallback = =>
      @translatedLocales.push(locale)
      $button.trigger('addedLocale.translationManager', locale)
      @changeLocale(locale)
      @refreshButtonStates()

    $localePanes = @getLocalePanes(locale, true)
    if $localePanes.any()
      $localePanes.removeClass('removed')
      @markTranslationDestroyed(locale, false)
      addedLocaleCallback()
    else
      @loadPane locale, =>
        addedLocaleCallback()
    true

  removeLocale: (locale) ->
    return false unless _.contains(@translatedLocales, locale)
    $button = @getRemoveLocaleButton(locale)
    $button.trigger('removingLocale.translationManager', locale)
    @markTranslationDestroyed(locale, true)
    @getLocalePanes(locale).addClass('removed')
    @refreshButtonStates()
    @translatedLocales.remove(locale)
    $button.trigger('removedLocale.translationManager', locale)
    @changeLocale(@getNeighborLocale(locale)) if @selectedLocale == locale
    true

  markTranslationDestroyed: (locale, destroy = true) ->
    @getDestroyTranslationInputs(locale).val(destroy)

  # Methods to query and control initial appearance

  queryInitialState: ->
    @availableLocales = @getAddLocaleButtons().map(-> $(@).data('locale')).toArray()
    @translatedLocales = _.uniq(@getPanes().map(-> $(@).data('locale')).toArray())
    @changeLocale(@getInitialLocale())

  getInitialLocale: ->
    _this = @
    localeWithErrors = null
    jQuery.each @translatedLocales, ->
      locale = @toString()
      $panes = _this.getLocalePanes(locale)
      if $('.form-group', $panes).any('.has-error')
        localeWithErrors = locale
        return false
    initialLocale = localeWithErrors || I18n.locale
    initialLocale = @translatedLocales.first() unless _.contains(@translatedLocales, initialLocale)
    initialLocale

  # Methods to refresh states for UI elements

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
      hidden = !_.contains(_this.translatedLocales, locale)
      _this.hideChangeLocaleButton(locale, hidden)

      # Changed: Active or inactive
      activated = _this.selectedLocale == locale
      _this.activateChangeLocaleButton(locale, activated)

  refreshAddLocaleButtonStates: ->
    _this = @
    @getAddLocaleButtons().each ->
      $button = $(@)
      locale = $button.data('locale')
      _this.disableAddLocaleButton(locale, _.contains(_this.translatedLocales, locale))

  refreshRemoveLocaleButtonStates: ->
    _this = @
    @getRemoveLocaleButtons().each ->
      $button = $(@)
      locale = $button.data('locale')
      _this.disableRemoveLocaleButton(locale, _this.translatedLocales.length <= 1)

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

  # Getters for UI elements: Buttons

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

  getAdditionalUrlParams: ->
    {}

  # Getters for UI elements: Panes

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
    jQuery.ajax
      url: @url
      dataType: @dataType
      data: jQuery.extend({}, @getAdditionalUrlParams(), translated_locale: locale)
      success: (data) =>
        $(data).appendTo(@container.find('.tab-content')).prepare() if @dataType == 'html'
        callback() if callback  
      error: =>
        alert I18n.translate('translations.error')

  # Helpers
  getNeighborLocale: ->
    index = _.indexOf(@translatedLocales, @selectedLocale)
    locale = @translatedLocales[index + 1]
    locale ||= @translatedLocales[index - 1]
    locale

  localeFilter = (locale) ->
    jQuery.error 'locale not defined' if !locale or locale == ''
    "[data-locale='#{locale}']"


# jQuery Plugin

$.fn.translationManager = (klass) ->
  @each ->
    $container = $(@)
    klass ||= window[$container.data('type')] || TranslationManager
    translationManager = new klass($container)
    $container.data('translationManager', translationManager)

  # hotfix for non-disappearing tooltips
  @on 'removedLocale.translationManager', ->
    $('.tooltip', @).remove()

$(document).ready ->
  $('.translation-manager').translationManager()
