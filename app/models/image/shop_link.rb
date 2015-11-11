class Image < ActiveRecord::Base
  class ShopLink < ActiveRecord::Base
    include UrlContainable

    belongs_to :image, required: true, touch: true
    belongs_to :provider, required: true

    delegate :name, :logo, to: :provider, prefix: true, allow_nil: true

    def to_param
      [id, provider_name.try(:parameterize)].compact.join('-')
    end
  end
end
