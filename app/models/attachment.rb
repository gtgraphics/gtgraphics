# == Schema Information
#
# Table name: attachments
#
#  id                :integer          not null, primary key
#  asset             :string(255)
#  content_type      :string(255)
#  file_size         :integer
#  asset_updated_at  :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  author_id         :integer
#  original_filename :string(255)
#  asset_token       :string(255)      not null
#

class Attachment < ActiveRecord::Base
  include FileAttachable
  include Ownable
  include PersistenceContextTrackable
  include Sortable
  include Translatable

  translates :title, :description, fallbacks_for_empty_translations: true

  has_attachment
  has_owner :author, default_owner_to_current_user: false

  validates :asset, presence: true

  before_validation :set_default_title, on: :create

  acts_as_sortable do |by|
    by.title(default: true) { |dir| Attachment::Translation.arel_table[:title].send(dir.to_sym) }
    by.file_size { |dir| arel_table[:file_size].send(dir.to_sym) }
    by.updated_at { |dir| arel_table[:updated_at].send(dir.to_sym) }
  end

  def image?
    content_type.in?(Image.permitted_content_types)
  end

  def to_image
    raise 'cannot be converted to Image' unless image?
    Image.new do |image|
      image.asset = asset
      image.original_filename = original_filename
      image.content_type = content_type
      image.file_size = file_size
      image.asset_updated_at = asset_updated_at
      image.author_id = author_id
      translated_locales.each do |translated_locale|
        Globalize.with_locale(translated_locale) do
          image.title = title
          image.description = description
        end
      end
    end
  end

  private
  def set_default_title
    if title.blank? and original_filename.present?
      self.title = File.basename(original_filename, '.*').titleize
    end
  end
end
