class @PageTranslationManager extends @TranslationManager
  constructor: ($container) ->
    super
    @dataType = 'script'

  getAdditionalUrlParams: ->
    { embeddable_type: @getPageEmbeddableManager().getEmbeddableType() }

  getPageEmbeddableManager: ->
    @container.closest('.embeddable-manager').data('pageEmbeddableManager')