# == Schema Information
#
# Table name: user_social_links
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  provider_id :integer
#  url         :string
#  shop        :boolean          default(FALSE), not null
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class User < ActiveRecord::Base
  class SocialLink < ActiveRecord::Base
    include UrlContainable

    belongs_to :user, required: true, touch: true
    belongs_to :provider, required: true

    delegate :name, :logo, to: :provider, prefix: true, allow_nil: true

    acts_as_list scope: %i(user shop)

    default_scope -> { order(:position) }

    validates :provider, uniqueness: { scope: %i(user shop),
                                       allow_blank: true }

    scope :networks, -> { where(shop: false) }
    scope :shops, -> { where(shop: true) }

    def to_param
      [id, provider_name.try(:parameterize)].compact.join('-')
    end
  end
end
