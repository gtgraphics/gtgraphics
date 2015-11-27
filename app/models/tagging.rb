# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  tag_id        :integer          not null
#  taggable_id   :integer          not null
#  taggable_type :string           not null
#

class Tagging < ActiveRecord::Base
  belongs_to :tag, autosave: true
  belongs_to :taggable, polymorphic: true

  after_destroy :destroy_unused_tag

  delegate :label, to: :tag

  private

  def destroy_unused_tag
    tag.destroy unless Tagging.exists?(tag: tag)
  end
end
