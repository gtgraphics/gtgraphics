detectIE = ->
  ua = window.navigator.userAgent
  msie = ua.indexOf('MSIE ')
  trident = ua.indexOf('Trident/')

  # IE 10 or older => return version number
  return Number(ua.substring(msie + 5, ua.indexOf('.', msie))) if msie > 0

  if trident > 0
    rv = ua.indexOf('rv:')
    return Number(ua.substring(rv + 3, ua.indexOf('.', rv)))

  # other browser
  false

$(document).ready ->
  ie = detectIE()
  $('html').addClass('ie').addClass("ie#{ie}") if ie
