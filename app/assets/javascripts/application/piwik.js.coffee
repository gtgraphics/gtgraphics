$(document).on 'page:change', ->
  if window._paq?
    _paq.push ['trackPageView']
    _paq.push(['setCustomUrl', document.location]);
    _paq.push(['setDocumentTitle', document.title]);
    _paq.push(['enableLinkTracking']);
  else if window.piwikTracker?
    piwikTracker.trackPageview()
