module TrackingHelper
  def include_tracking_script
    return unless Rails.env.production?
    capture do
      concat javascript_tag <<-JAVASCRIPT.strip_heredoc
        var _paq = _paq || [];

        (function() {
          var u=(("https:" == document.location.protocol) ? "https" : "http") + "://stats.spdns.de/";
          _paq.push(['setTrackerUrl', u+'piwik.php']);
          _paq.push(['setSiteId', 5]);
          var piwikUrl = u + 'piwik.js';
          var d = document;
          var g = d.createElement('script');
          g.type = 'text/javascript';
          var s = d.getElementsByTagName('script')[0];
          if (s.src != piwikUrl) {
            g.defer=true; g.async=true; g.src=piwikUrl; s.parentNode.insertBefore(g,s);
          }
        })();
      JAVASCRIPT
      concat '<noscript><p><img src="http://stats.spdns.de/piwik.php?idsite=5" ' \
             'style="border:0;" alt="" /></p></noscript>'.html_safe
    end
  end
end
