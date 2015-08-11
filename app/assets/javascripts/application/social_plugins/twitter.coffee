class Twitter
  constructor: ->
    @loaded = false

  load: ->
    @init()
    jQuery.getScript('https://platform.twitter.com/widgets.js')

  init: ->
    $('.twitter-share-button').each ->
      $button = $(@)
      $button.attr('data-url', document.location.href) unless $button.data('url')?
      $button.attr('data-text', document.title) unless $button.data('text')?

twitter = new Twitter
$(document).ready ->
  twitter.load()
  console.debug 'Social plugin loaded: Twitter'
