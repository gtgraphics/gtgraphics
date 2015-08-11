class PagePresenter < ApplicationPresenter
  presents :page

  delegate_presented :embeddable

  def permalink
    h.page_permalink_url(page.permalink, protocol: :http, locale: nil)
  end

  def social_uri
    page.metadata.fetch(:social_uri) { permalink }
  end

  def url
    h.page_url(page, protocol: :http)
  end

  # Facebook Integration

  def facebook_like_button(options = {})
    h.facebook_like_button(social_uri, options)
  end

  def facebook_comments(options = {})
    h.facebook_comments(social_uri, options.reverse_merge(colorscheme: :dark))
  end

  # Google Plus Integration

  def google_plus_like_button(options = {})
    h.google_plus_like_button(url, options)
  end

  # Twitter Integration

  def twitter_share_button(options = {})
    text = embeddable.try(:twitter_share_text) || title
    options = options.reverse_merge(text: text, url: social_uri)
    h.twitter_share_button(options)
  end
end
