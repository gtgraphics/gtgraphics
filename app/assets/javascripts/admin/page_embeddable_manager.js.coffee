class @PageEmbeddableManager
  constructor: ($container) ->
    @container = $container
    @url = $container.data('loadUrl')
    @translationManager = $('.translation-manager', @container).data('translationManager') # TODO Not yet loaded at this point
    @queryInitialState()
    @applyEvents()

  queryInitialState: ->
    @availableEmbeddableTypes = @getAvailableEmbeddableTypes()
    @embeddableType = @getEmbeddableType()

  applyEvents: ->
    @getEmbeddableTypeSelect().change =>
      @changeEmbeddableType(@getEmbeddableType())
      true

  changeEmbeddableType: (type) ->
    return false if type == @embeddableType
    return false unless @availableEmbeddableTypes.include(type)
    $embeddableType = @getEmbeddableTypeSelect()
    $embeddableType.trigger('changingEmbeddableType.pageEmbeddableManager', type)
    @setEmbeddableType(type)
    @loadEmbeddableFields type, ->
      @embeddableType = type
      $embeddableType.trigger('changedEmbeddableType.pageEmbeddableManager', type)
    true

  loadEmbeddableFields: (type, callback) ->
    jQuery.ajax
      url: @url
      dataType: 'script'
      data: { embeddable_type: type }
      success: ->
        callback() if callback
      error: =>
        alert I18n.translate('pages.embeddable.error')
        @setEmbeddableType(@embeddableType)

  # Getters/Setters

  getEmbeddableTypeSelect: ->
    $('select.embeddable-type-select', @container)

  getEmbeddableType: ->
    @getEmbeddableTypeSelect().select2('val')

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