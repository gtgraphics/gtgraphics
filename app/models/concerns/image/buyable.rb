module Image::Buyable
  extend ActiveSupport::Concern

  SHOP_PROVIDERS = %w(
    deviantart
    fineartprint
    mygall
    redbubble
    artflakes
  ).freeze

  included do
    has_many :buy_requests, class_name: 'Message::BuyRequest', foreign_key: :delegator_id, dependent: :destroy

    store :shop_urls

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
  end

  module ClassMethods
    def available_shop_providers
      SHOP_PROVIDERS
    end
  end
end