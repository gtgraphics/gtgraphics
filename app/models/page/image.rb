# == Schema Information
#
# Table name: image_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  image_id    :integer          not null
#  shop_urls   :text
#

class Page < ActiveRecord::Base
  class Image < ActiveRecord::Base
    include Page::Concrete

    SHOP_PROVIDERS = %w(
      deviantart
      fineartprint
      mygall
      redbubble
      artflakes
    ).freeze

    acts_as_concrete_page

    belongs_to :image, class_name: '::Image', inverse_of: :image_pages

    validates :image, presence: true

    store :shop_urls

    delegate :title, to: :image, allow_nil: true
    delegate :format, to: :image

    def self.available_shop_providers
      SHOP_PROVIDERS
    end

    SHOP_PROVIDERS.each do |shop_provider|
      class_eval <<-RUBY
        def #{shop_provider}_url
          read_store_attribute :shop_urls, :#{shop_provider}
        end

        def #{shop_provider}_url=(url)
          write_store_attribute :shop_urls, :#{shop_provider}, url
        end
      RUBY

      validates :"#{shop_provider}_url", url: true, allow_blank: true
    end

    def to_liquid
      { 'image' => image }
    end

    def to_title
      image.try(:title)
    end
  end
end
