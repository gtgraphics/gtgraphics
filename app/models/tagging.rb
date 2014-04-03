# == Schema Information
#
# Table name: taggings
#
#  tag_id        :integer          not null
#  taggable_id   :integer          not null
#  taggable_type :string(255)      not null
#

class Tagging < ActiveRecord::Base
  belongs_to :tag, autosave: true
  belongs_to :taggable, polymorphic: true

  delegate :label, to: :tag
end
