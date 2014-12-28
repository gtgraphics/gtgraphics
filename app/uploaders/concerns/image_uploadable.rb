module ImageUploadable
  extend ActiveSupport::Concern

  included do
    include CarrierWave::RMagick
    include CarrierWave::MimeTypes

    process :set_content_type

    version :custom do
      process :crop
      process :resize
      process :strip

      def full_filename(file)
        "custom/#{file}"
      end
    end

    version :public, from_version: :custom do
      process :watermark
      process convert: 'jpeg'
      process quality: 85

      def filename
        super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
      end

      def full_filename(file)
        "public/#{file}"
      end
    end

    version :thumbnail, from_version: :custom do
      process resize_to_fill: [45, 45]
      process convert: 'jpeg'
      process quality: 85

      def filename
        super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
      end

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
      img.resize!(model.resize_width, model.resize_height)
      img = yield(img) if block_given?
      img
    end
  end

  def resized?
    model.try(:resized?) || false
  end

  def watermark
    manipulate! do |img|
      watermark = Magick::Image.read("#{Rails.root}/config/watermark.png").first
      img = img.composite(watermark, Magick::SouthEastGravity,
                          0, 0, Magick::OverCompositeOp)
      img = yield(img) if block_given?
      img
    end
  end

  def strip
    manipulate! do |img|
      img.strip!
      img = yield(img) if block_given?
      img
    end
  end

  def quality(percentage)
    manipulate! do |img|
      unless img.quality == percentage
        img.write(current_path) do
          self.quality = percentage
        end
      end
      img = yield(img) if block_given?
      img
    end
  end
end
