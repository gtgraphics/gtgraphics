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
#  original_filename  :string(255)
#

class Attachment < ActiveRecord::Base
  include FileAttachable
  # include AttachmentPreservable
  include Ownable
  include PersistenceContextTrackable
  include Sortable
  include Translatable

  translates :title, :description, fallbacks_for_empty_translations: true

  has_attachment
  has_owner :author, default_owner_to_current_user: false

  # preserve_attachment_between_requests_for :asset

  before_validation :set_default_title, if: :file_name?, unless: :title?

  acts_as_sortable do |by|
    by.file_size { |dir| arel_table[:asset_file_size].send(dir.to_sym) }
    by.title(default: true) { |dir| Attachment::Translation.arel_table[:title].send(dir.to_sym) }
    by.updated_at { |dir| arel_table[:updated_at].send(dir.to_sym) }
  end

  def image?
    content_type.in?(Image.permitted_content_types)
  end

  private
  def set_default_title
    self.title = File.basename(file_name, '.*').titleize
  end
end
