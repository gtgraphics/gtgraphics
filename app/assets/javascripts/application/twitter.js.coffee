twitterEventsBound = false

bindTwitterEventHandlers = ->
  $(document).on 'page:load', renderTweetButtons
  twitterEventsBound = true

renderTweetButtons = ->
  $('.twitter-share-button').each ->
    button = $(this)
    button.attr('data-url', document.location.href) unless button.data('url')?
    button.attr('data-text', document.title) unless button.data('text')?
  twttr.widgets.load()

loadTwitterSDK = ->
  jQuery.getScript('//platform.twitter.com/widgets.js')

$(document).ready ->
  loadTwitterSDK()
  bindTwitterEventHandlers() unless twitterEventsBound
