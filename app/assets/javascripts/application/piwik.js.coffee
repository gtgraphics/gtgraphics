$(document).on 'page:change', ->
  if window._paq?
    _paq.push ['trackPageView']
  else if window.piwikTracker?
    piwikTracker.trackPageview()
