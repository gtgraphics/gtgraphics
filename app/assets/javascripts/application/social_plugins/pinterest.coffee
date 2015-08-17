class Pinterest
  constructor: ->
    @loaded = false

  load: ->
    delete window["PIN_"+~~((new Date).getTime()/864e5)]
    jQuery.getScript("//assets.pinterest.com/js/pinit.js")
    @loaded = true

pinterest = new Pinterest
$(document).ready ->
  pinterest.load()
  console.debug 'Social plugin loaded: Pinterest'
