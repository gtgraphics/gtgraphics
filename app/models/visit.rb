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
end
