module TrackingHelper
  TRACKING_SCRIPT_URL = '//stats.spdns.de/piwik.js'
  TRACKING_URL = '//stats.spdns.de/piwik.php'
  SITE_ID = '45375739'

  def include_tracking_elements
    return unless Rails.env.production?
    snippet = <<-HTML.strip_heredoc
      <!-- Piwik -->
      <script type="text/javascript">
        var _paq = _paq || [];
        _paq.push(['setCustomUrl', document.location]);
        _paq.push(['setDocumentTitle', document.title]);
        _paq.push(['trackPageView']);
        _paq.push(['enableLinkTracking']);
        (function() {
          var u=(("https:" == document.location.protocol) ? "https" : "http") + "://stats.spdns.de/";
          _paq.push(['setTrackerUrl', u+'piwik.php']);
          _paq.push(['setSiteId', 5]);
          var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0]; g.type='text/javascript';
          g.defer=true; g.async=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
        })();
      </script>
      <noscript><p><img src="http://stats.spdns.de/piwik.php?idsite=5" style="border:0;" alt="" /></p></noscript>
      <!-- End Piwik Code -->
    HTML
    snippet.html_safe
  end
end
