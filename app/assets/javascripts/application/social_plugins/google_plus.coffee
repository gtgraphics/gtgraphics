class GooglePlus
  constructor: ->
    @loaded = false
    if I18n.locale == 'de'
      @locale = 'de'
    else
      @locale = 'en_US'
    @load()

  load: ->
    return @init() if @loaded
    window.___gcfg = { lang: @locale, parsetags: 'explicit' }
    jQuery.getScript 'https://apis.google.com/js/plusone.js', =>
      @init()
      @loaded = true

  init: ->
    gapi.plusone.go()

gplus = new GooglePlus
$(document).ready ->
  gplus.load()
  console.debug 'Social plugin loaded: Google Plus'
