$(document).on 'page:change', ->
  if window._paq?
    _paq.push ['setCustomUrl', document.location]
    _paq.push ['setDocumentTitle', document.title]
    _paq.push ['setDownloadClasses', 'download']
    _paq.push ['enableLinkTracking']
    _paq.push ['trackPageView']
  else if window.piwikTracker?
    piwikTracker.trackPageview()
