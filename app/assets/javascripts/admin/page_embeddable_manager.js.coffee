class @PageEmbeddableManager
  constructor: ($container) ->
    @container = $container
    @translationManager = $('.translation-manager', @container).data('translationManager') # TODO Not yet loaded at this point


# jQuery Plugin

$.fn.pageEmbeddableManager = ->
  @each ->
    $container = $(@)
    embeddableManager = new PageEmbeddableManager($container)
    $container.data('pageEmbeddableManager', embeddableManager)

$(document).ready ->
  $('.embeddable-manager').pageEmbeddableManager()