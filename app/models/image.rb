# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  asset_file_name    :string(255)
#  asset_content_type :string(255)
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  width              :integer
#  height             :integer
#  exif_data          :text
#  created_at         :datetime
#  updated_at         :datetime
#  author_id          :integer
#

class Image < ActiveRecord::Base
  include Authorable
  # include AttachmentPreservable
  include BatchTranslatable
  include ImageContainable
  include PageEmbeddable
  include PersistenceContextTrackable
  include Sortable
  include Templatable

  CONTENT_TYPES = ImageContainable::CONTENT_TYPES
  EXIF_CAPABLE_CONTENT_TYPES = [Mime::JPEG].freeze

  STYLES = {
    thumbnail: ['75x75#', :png],
    large_thumbnail: ['253x190#', :png],
    preview: '1170x',
    medium: '1280x780',
    large: '1920x1080'
  }

  self.template_type = 'Template::Image'.freeze

  has_many :styles, class_name: 'Image::Style', dependent: :destroy

  translates :title, :description, fallbacks_for_empty_translations: true

  acts_as_authorable default_to_current_user: false
  acts_as_batch_translatable
  acts_as_image_containable styles: STYLES, url: '/system/images/:id/:style.:extension'
  acts_as_page_embeddable multiple: true, destroy_with_page: false
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.title(default: true) { |column, dir| Image::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end
  # preserve_attachment_between_requests_for :asset

  serialize :exif_data, OpenStruct

  before_validation :set_default_title
  before_save :set_exif_data, if: :asset_changed?

  class << self
    def content_types
      CONTENT_TYPES
    end
  end

  def description_html
    template = Liquid::Template.parse(description)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    {} # TODO
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

  def to_s
    title
  end

  private
  def set_default_title
    translation.title = File.basename(asset_file_name, '.*').humanize if asset_file_name.present? and translation.title.blank?
  end

  def set_exif_data
    if asset_content_type.in?(EXIF_CAPABLE_CONTENT_TYPES)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end
end
