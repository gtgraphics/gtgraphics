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
      console.log 'init'
      @init()
    else
      console.log 'load + init'
      window.___gcfg = { lang: @locale, parsetags: 'explicit' }
      jQuery.getScript 'https://apis.google.com/js/plusone.js', =>
        @init()

  init: ->
    gapi.plusone.go()
    GooglePlus.initialized = true

$(document).ready ->
  new GooglePlus
