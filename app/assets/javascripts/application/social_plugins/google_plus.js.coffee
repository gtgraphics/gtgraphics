class GooglePlus
  @initialized = false

  constructor: ->
    if I18n.locale == 'de'
      @locale = 'de'
    else
      @locale = 'en_US'
    @load()

  load: (callback) ->
    if GooglePlus.initialized
      @init()
    else
      window.___gcfg = { lang: @locale, parsetags: 'explicit' }
      jQuery.getScript 'https://apis.google.com/js/plusone.js', =>
        @init()

  init: ->
    gapi.plusone.go()

$(document).ready ->
  new GooglePlus
