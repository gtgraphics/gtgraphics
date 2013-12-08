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
#

class Attachment < ActiveRecord::Base
  include AssetContainable
  # include AttachmentPreservable
  include BatchTranslatable

  translates :title, :description, fallbacks_for_empty_translations: true

  has_attached_file :asset, url: '/system/:class/:id_partition/:filename'

  acts_as_batch_translatable
  # preserve_attachment_between_requests_for :asset

  validates_attachment :asset, presence: true

  before_validation :set_default_title

  def description_html(locale = I18n.locale)
    template = Liquid::Template.parse(self.description(locale))
    template.render(to_liquid).html_safe
  end

  def image?
    content_type.in?(Image::CONTENT_TYPES)
  end

  def to_liquid
    {} # TODO
  end

  private
  def set_default_title
    translation.title = File.basename(asset_file_name, '.*').humanize if asset_file_name.present? and translation.title.blank?
  end
end
