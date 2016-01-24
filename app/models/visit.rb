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
end
