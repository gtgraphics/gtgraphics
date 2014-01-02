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
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include HtmlContainable
  include PersistenceContextTrackable
  include Sortable

  translates :title, :description, fallbacks_for_empty_translations: true

  acts_as_asset_containable url: '/system/:class/:id_partition/:filename'
  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_html_containable :description
  # preserve_attachment_between_requests_for :asset

  validates_attachment :asset, presence: true

  before_validation :set_default_title

  acts_as_sortable do |by|
    by.file_size { |dir| arel_table[:asset_file_size].send(dir.to_sym) }
    by.title(default: true) { |dir| Attachment::Translation.arel_table[:title].send(dir.to_sym) }
    by.updated_at { |dir| arel_table[:updated_at].send(dir.to_sym) }
  end

  def description_html
    template = Liquid::Template.parse(self.description)
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
