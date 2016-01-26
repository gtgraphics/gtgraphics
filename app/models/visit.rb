# == Schema Information
#
# Table name: hits
#
#  id            :integer          not null, primary key
#  hittable_id   :integer          not null
#  hittable_type :string           not null
#  created_at    :datetime         not null
#  referer       :string
#  user_agent    :string
#  type          :string
#  ip            :string(11)
#

class Visit < Hit
  self.counter_cache = :visits_count

  alias_attribute :visitable_type, :hittable_type
  alias_attribute :visitable_id, :hittable_id
  alias_method :visitable, :hittable

  belongs_to :page, foreign_key: :hittable_id

  after_initialize :set_default_hittable_type

  private

  def set_default_hittable_type
    self.hittable_type = 'Page'
  end
end
