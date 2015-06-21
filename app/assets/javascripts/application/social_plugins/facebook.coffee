class Facebook
  @initialized = false

  constructor: ->
    @appId = $('meta[property="fb:app_id"]').attr('content')
    if I18n.locale == 'de'
      @locale = 'de_DE'
    else
      @locale = 'en_US'
    @$fbRoot = null
    @load()

  load: ->
    return if Facebook.initialized
    jQuery.getScript "//connect.facebook.net/#{@locale}/all.js#xfbml=1", =>
      @init()

  init: ->
    return if Facebook.initialized
    FB.init(appId: @appId, status: true, cookie: true, xfbml: true)
    @bindEvents()
    Facebook.initialized = true

  bindEvents: ->
    $(document)
      .on('page:fetch', @saveFacebookRoot)
      .on('page:change', @restoreFacebookRoot)
      .on('page:load', @parseElements)

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

$(document).ready ->
  new Facebook
