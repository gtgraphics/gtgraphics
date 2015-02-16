class Twitter
  @initialized = false

  constructor: ->
    @load()

  load: ->
    return if Twitter.initialized
    jQuery.getScript '//platform.twitter.com/widgets.js', =>
      @bindEvents()
      Twitter.initialized = true

  init: ->
    $('.twitter-share-button').each ->
      $button = $(this)
      $button.attr('data-url', document.location.href) unless $button.data('url')?
      $button.attr('data-text', document.title) unless $button.data('text')?
    twttr.widgets.load()

  bindEvents: ->
    $(document).on 'page:load', =>
      @init()

$(document).ready ->
  new Twitter
