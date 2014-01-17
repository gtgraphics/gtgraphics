class @PageEmbeddableManager
  constructor: ($container) ->
    @container = $container
    @url = $container.data('url')
    @queryInitialState()
    @applyEvents()

  queryInitialState: ->
    @availableEmbeddableTypes = @getAvailableEmbeddableTypes()
    @embeddableType = @getEmbeddableType()
    @getEmbeddableFieldsContainer().attr('data-type', @embeddableType)

  applyEvents: ->
    @getEmbeddableTypeSelect().change =>
      @changeEmbeddableType(@getEmbeddableType())
      true

  changeEmbeddableType: (type) ->
    return false if type == @embeddableType
    return false unless _.contains(@availableEmbeddableTypes, type)
    $embeddableType = @getEmbeddableTypeSelect()
    $embeddableType.trigger('changingEmbeddableType.pageEmbeddableManager', type)
    @setEmbeddableType(type)
    @loadEmbeddableFields type, =>
      @embeddableType = type
      $embeddableType.trigger('changedEmbeddableType.pageEmbeddableManager', type)
      @getEmbeddableFieldsContainer().attr('data-type', @embeddableType)
    true

  loadEmbeddableFields: (type, callback) ->
    jQuery.ajax
      url: @url
      dataType: 'html'
      data: {
        translated_locales: @getTranslatedLocales()
        embeddable_type: type
      }
      success: (html) =>
        $embeddableFieldsContainer = @getEmbeddableFieldsContainer()
        $embeddableFieldsContainer.html(html).prepare()
        $embeddableTranslations = @getTranslationsContainer($embeddableFieldsContainer)
        @getTranslationManager().showSelectedLocalePanes()
        callback() if callback
      error: =>
        alert I18n.translate('pages.embeddable.error')
        @setEmbeddableType(@embeddableType) # restore select to previous embeddable type

  # DOM Element Getters

  getEmbeddableTranslationFieldsContainer: ->
    @getTranslationsContainer(@getEmbeddableFieldsContainer())

  getEmbeddableTypeSelect: ->
    $('select.embeddable-type-select', @container)

  getEmbeddableFieldsContainer: ->
    $('.embeddable-fields', @container)

  getTranslationsContainer: ($scope) ->
    $scope ||= @container
    $('.translations', $scope)

  # Getters/Setters

  getEmbeddableType: ->
    @getEmbeddableTypeSelect().select2('val')

  getTranslationManager: ->
    $('.translation-manager', @container).data('translationManager')

  getTranslatedLocales: ->
    @getTranslationManager().translatedLocales

  getAvailableEmbeddableTypes: ->
    @getEmbeddableTypeSelect().options()

  setEmbeddableType: (type) ->
    @getEmbeddableTypeSelect().select2('val', type)

# jQuery Plugin

$.fn.pageEmbeddableManager = ->
  @each ->
    $container = $(@)
    embeddableManager = new PageEmbeddableManager($container)
    $container.data('pageEmbeddableManager', embeddableManager)

$(document).ready ->
  $('.embeddable-manager').pageEmbeddableManager()