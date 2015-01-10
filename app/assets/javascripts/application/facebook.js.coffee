$fbRoot = null
facebookEventsBound = false

bindFacebookEvents = ->
  $(document)
    .on('page:fetch', saveFacebookRoot)
    .on('page:change', restoreFacebookRoot)
    .on('page:load', ->
      FB?.XFBML.parse()
    )
  facebookEventsBound = true

saveFacebookRoot = ->
  $fbRoot = $('#fb-root').detach()

restoreFacebookRoot = ->
  if $('#fb-root').length > 0
    $('#fb-root').replaceWith $fbRoot
  else
    $('body').append $fbRoot

loadFacebookSDK = ->
  window.fbAsyncInit = initializeFacebookSdk
  if I18n.locale == 'de'
    locale = 'de_DE'
  else
    locale = 'en_US'
  jQuery.getScript("//connect.facebook.net/#{locale}/all.js#xfbml=1")

initializeFacebookSdk = ->
  appId = $('meta[property="fb:app_id"]').attr('content')
  FB.init(appId: appId, status: true, cookie: true, xfbml: true)

$(document).ready ->
  loadFacebookSDK()
  bindFacebookEvents() unless facebookEventsBound
