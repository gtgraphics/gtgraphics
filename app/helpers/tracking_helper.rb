module TrackingHelper
  def include_tracking_script
    return unless Rails.env.production?
    capture do
      concat javascript_tag <<-JAVASCRIPT.strip_heredoc
        var _paq = _paq || [];
        _paq.push(['setCustomUrl', document.location]);
        _paq.push(['setDocumentTitle', document.title]);
        _paq.push(['enableLinkTracking']);
        (function() {
          var u=(("https:" == document.location.protocol) ? "https" : "http") + "://stats.spdns.de/";
          _paq.push(['setTrackerUrl', u+'piwik.php']);
          _paq.push(['setSiteId', 5]);
          var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0]; g.type='text/javascript';
          g.defer=true; g.async=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
        })();
      JAVASCRIPT
      concat '<noscript><p><img src="http://stats.spdns.de/piwik.php?idsite=5" ' \
             'style="border:0;" alt="" /></p></noscript>'.html_safe
    end
  end
end
