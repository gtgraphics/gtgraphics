module ImageUploadable
  extend ActiveSupport::Concern

  included do
    include CarrierWave::RMagick
    include CarrierWave::MimeTypes

    class_attribute :watermark, instance_accessor: false
    self.watermark = false

    process :set_content_type
  
    version :custom do
      process :crop
      process :resize
      process :watermark

      def full_filename(file)
        "custom/#{file}"
      end
    end

    version :thumbnail, from_version: :custom do
      process resize_to_fill: [300, 300]

      def full_filename(file)
        "thumbnails/#{file}"
      end
    end
  end

  protected
  def crop
    return unless cropped?
    manipulate! do |img|
      img.crop!(model.crop_x, model.crop_y, model.crop_width, model.crop_height)
      img = yield(img) if block_given?
      img
    end
  end

  def cropped?
    model.try(:cropped?) || false
  end

  def resize
    return unless resized?
    manipulate! do |img|
      img.resize_to_fit!(model.resize_width, model.resize_height)
      img = yield(img) if block_given?
      img
    end
  end

  def resized?
    model.try(:resized?) || false
  end

  def watermarked?
    if model.respond_to?(:watermarked?)
      model.watermarked?
    else
      self.class.watermark
    end
  end

  def watermark
    return unless watermarked?
    manipulate! do |img|
      watermark = Magick::Image.read("#{Rails.root}/config/watermark.png").first
      img = img.composite(watermark, Magick::SouthEastGravity, 0, 0, Magick::OverCompositeOp)
      img = yield(img) if block_given?
      img
    end
  end
end