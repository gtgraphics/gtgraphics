class @PageTranslationManager extends @TranslationManager
  constructor: ($container) ->
    super
    @dataType = 'script'
    @embeddableManagerContainer = @container.closest('.embeddable-manager')
    #@addEmbeddableManagerEvents()

  addLocale: (locale) ->
    return false if @loading or _.contains(@translatedLocales, locale)
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
      embeddableManager = @getPageEmbeddableManager()
      $embeddableTranslationFieldsContainer = embeddableManager.getEmbeddableTranslationFieldsContainer()
      oldEmbeddableType = embeddableManager.getEmbeddableFieldsContainer().data('type')
      newEmbeddabletype = embeddableManager.embeddableType
      if oldEmbeddableType != newEmbeddabletype
        @loadEmbeddableTranslationFields(locale, addedLocaleCallback)
      else
        addedLocaleCallback()
    else
      @loadPane(locale, addedLocaleCallback)
    true

  loadEmbeddableTranslationFields: (locale, callback) ->
    embeddableManager = @getPageEmbeddableManager()
    $embeddableFieldsContainer = embeddableManager.getEmbeddableFieldsContainer()
    translationUrl = $embeddableFieldsContainer.data('translationUrl')
    jQuery.ajax
      url: translationUrl
      dataType: 'html'
      data: {
        translated_locale: locale
        embeddable_type: @getEmbeddableType()
      }
      success: (html) =>
        $embeddableTranslationFieldsContainer = embeddableManager.getEmbeddableTranslationFieldsContainer()
        $(html).appendTo($embeddableTranslationFieldsContainer).prepare()
        @showSelectedLocalePanes()
        callback() if callback
      error: =>
        alert I18n.translate('javascript.translations.error')

  getAdditionalUrlParams: ->
    { embeddable_type: @getEmbeddableType() }

  getEmbeddableType: ->
    @getPageEmbeddableManager().getEmbeddableType()

  getPageEmbeddableManager: ->
    @embeddableManagerContainer.data('pageEmbeddableManager')