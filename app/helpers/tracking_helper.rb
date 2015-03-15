module TrackingHelper
  TRACKING_SCRIPT_URL = '//stats.spdns.de/piwik.js'
  TRACKING_URL = '//stats.spdns.de/piwik.php'
  SITE_ID = '45375739'

  def include_tracking_elements
    return unless Rails.env.production?
    capture do
      concat javascript_tag <<-JAVASCRIPT.strip_heredoc
        document.write(unescape("%3Cscript src='#{TRACKING_SCRIPT_URL}' type='text/javascript'%3E%3C/script%3E"));
      JAVASCRIPT
      concat javascript_tag <<-JAVASCRIPT.strip_heredoc
        try {
          var tracker = Piwik.getTracker('#{TRACKING_URL}', #{SITE_ID});
          tracker.trackPageView();
          tracker.enableLinkTracking();
        } catch( err ) {}
      JAVASCRIPT
      concat content_tag(
        :noscript, image_tag("#{TRACKING_URL}?idsite=#{SITE_ID}")
      )
    end
  end
end
