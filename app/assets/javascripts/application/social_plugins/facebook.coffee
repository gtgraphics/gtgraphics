class Facebook
  constructor: ->
    @loaded = false

    @$fbRoot = null

  load: ->
    return if @loaded
    locale = @determineLocale()
    jQuery.getScript "https://connect.facebook.net/#{locale}/all.js#xfbml=1", =>
      appId = $('meta[property="fb:app_id"]').attr('content')
      FB.init(appId: appId, status: true, cookie: true, xfbml: true)
      @bindEvents()
      @loaded = true

  bindEvents: ->
    $(document)
      .on('page:fetch', @saveFacebookRoot)
      .on('page:change', @restoreFacebookRoot)
      .on('page:load', @parseElements)

  determineLocale: ->
    if I18n.locale == 'de'
      'de_DE'
    else
      'en_US'

  parseElements: ->
    FB?.XFBML.parse()

  saveFacebookRoot: ->
    @$fbRoot = $('#fb-root').detach()

  restoreFacebookRoot: ->
    $fbRoot = $('#fb-root')
    if $fbRoot.length
      $fbRoot.replaceWith(@$fbRoot)
    else
      $('body').append(@$fbRoot)

facebook = new Facebook
$(document).ready ->
  facebook.load()
  console.debug 'Social plugin loaded: Facebook'
