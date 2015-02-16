class Page::ImagePresenter < Page::ApplicationPresenter
  presents :image_page

  def page
    present object.page # duplication due to eager loading bug
  end

  delegate_presented :image
  delegate :shop_links, to: :image

  def twitter_share_text
    twitter_username = image_page.image.author.try(:twitter_username)
    I18n.translate twitter_username.present? ? :owned : :ownerless,
                   scope: ['page/image', :twitter_share_text],
                   title: image_page.image.title,
                   author: twitter_username
  end
end
