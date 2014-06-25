# == Schema Information
#
# Table name: attachments
#
#  id                 :integer          not null, primary key
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  author_id          :integer
#

class Attachment < ActiveRecord::Base
  include AssetContainable
  include Ownable
  # include AttachmentPreservable
  include BatchTranslatable
  include PersistenceContextTrackable
  include Sortable

  translates :title, :description, fallbacks_for_empty_translations: true

  acts_as_asset_containable url: '/system/:class/:id_partition/:filename'
  acts_as_ownable :author, default_owner_to_current_user: false
  acts_as_batch_translatable

  do_not_validate_attachment_file_type :asset

  # preserve_attachment_between_requests_for :asset

  validates_attachment :asset, presence: true

  before_validation :set_default_title

  acts_as_sortable do |by|
    by.file_size { |dir| arel_table[:asset_file_size].send(dir.to_sym) }
    by.title(default: true) { |dir| Attachment::Translation.arel_table[:title].send(dir.to_sym) }
    by.updated_at { |dir| arel_table[:updated_at].send(dir.to_sym) }
  end

  def image?
    content_type.in?(Image::CONTENT_TYPES)
  end

  private
  def set_default_title
    if asset_file_name.present? and translation.title.blank?
      translation.title = File.basename(asset_file_name, '.*').humanize
    end
  end
end
