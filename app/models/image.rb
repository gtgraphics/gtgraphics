class Image < ActiveRecord::Base
  STYLES = {
    thumbnail: ['75x75#', :png],
    medium: ['1280x780', :jpeg],
    large: ['1920x1080', :jpeg]
  }

  translates :caption

  has_many :versions, class_name: 'Image::Version', dependent: :destroy

  has_attached_file :asset, styles: STYLES

  serialize :exif_data, OpenStruct

  before_validation :set_title
  before_validation :set_slug
  before_save :set_dimensions, if: :asset_changed?
  before_save :set_exif_data, if: :asset_changed?

  validates :title, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates_attachment :asset, presence: true, content_type: { content_type: %w(image/jpeg image/pjpeg image/gif image/png) }

  accepts_nested_attributes_for :versions, :translations

  def asset_changed?
    !asset.queued_for_write[:original].nil?
  end

  def aspect_ratio
    Rational(width, height)
  end

  def pixels
    size.inject(:*)
  end

  def size
    [width, height]
  end

  def to_param
    slug
  end

  def to_s
    title
  end

  private
  def set_dimensions
    geometry = Paperclip::Geometry.from_file(asset.queued_for_write[:original].path)
    self.width = geometry.width.to_i
    self.height = geometry.height.to_i
  end

  def set_exif_data
    if asset_content_type.in? %w(image/jpeg image/pjpeg)
      self.exif_data = OpenStruct.new(EXIFR::JPEG.new(asset.queued_for_write[:original].path).to_hash) rescue nil
    end
  end

  def set_slug
    if slug.blank?
      self.slug = title.parameterize
    else
      self.slug = slug.parameterize
    end
  end

  def set_title
    self.title = File.basename(asset.queued_for_write[:original].original_filename, '.*').humanize if title.blank?
  end
end