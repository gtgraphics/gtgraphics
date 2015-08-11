class Twitter
  constructor: ->
    @loaded = false

  load: ->
    return @init() if @loaded
    jQuery.getScript 'https://platform.twitter.com/widgets.js', =>
      @init()
      @loaded = true

  init: ->
    $('.twitter-share-button').each ->
      $button = $(@)
      $button.attr('data-url', document.location.href) unless $button.data('url')?
      $button.attr('data-text', document.title) unless $button.data('text')?
    twttr.widgets.load()

twitter = new Twitter
$(document).ready ->
  twitter.load()
  console.debug 'Social plugin loaded: Twitter'
