module Social::TwitterHelper
  def twitter_share_button(*args)
    options = args.extract_options!.reverse_merge(count: true)
    count = case options[:count]
            when true then nil
            when false, nil then 'none'
            else options[:count].to_s
            end

    link_to 'https://twitter.com/share',
            class: 'twitter-share-button',
            data: { text: options[:text], url: options[:url], lang: locale,
                    count: count } do
      content_tag(:span, translate('helpers.links.tweet'), class: 'sr-only')
    end
  end
end
