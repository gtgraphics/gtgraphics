module Social::TwitterHelper
  def twitter_share_button(*args)
    options = args.extract_options!.reverse_merge(count: false)
    count = options[:count] == false ? 'none' : options[:count].to_s

    link_to 'https://twitter.com/share',
            class: 'twitter-share-button',
            data: { text: options[:text], url: options[:url], lang: locale,
                    count: count } do
      content_tag(:span, translate('helpers.links.tweet'), class: 'sr-only')
    end
  end
end
