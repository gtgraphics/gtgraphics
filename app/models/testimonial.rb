# == Schema Information
#
# Table name: testimonials
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  slug        :string(255)
#  description :text
#  launched_on :date
#  client_name :string(255)
#  url         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Testimonial < ActiveRecord::Base
  include Sluggable

  acts_as_sluggable_on :title

  def to_s
    name
  end
end
