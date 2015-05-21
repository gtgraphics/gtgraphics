module TrackingHelper
  def include_tracking_script
    return unless Rails.env.production?
    capture do
      concat piwik_tracking_script
      concat google_analytics_tracking_script
    end
  end

  private

  def piwik_tracking_script
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

  def google_analytics_tracking_script
    javascript_tag(<<-JAVASCRIPT.strip_heredoc)
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-47701772-2', 'auto');
      ga('send', 'pageview');
    JAVASCRIPT
  end
end
