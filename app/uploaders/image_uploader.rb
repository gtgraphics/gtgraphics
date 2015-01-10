class ImageUploader < AttachmentUploader
  include ImageUploadable

  version :public, from_version: :custom do
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "public/#{file}"
    end
  end

  version :social, from_version: :custom do
    process resize_to_fill: [500, 500]
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "social/#{file}"
    end
  end

  version :brick, from_version: :custom do
    process resize_to_fit: [354, nil]
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "bricks/#{file}"
    end
  end

  version :menu_brick, from_version: :custom do
    process resize_to_fill: [530, 200]
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      "menu_bricks/#{file}"
    end
  end

  def store_dir
    'system/images'
  end

  def cache_dir
    'tmp/uploads/images'
  end
end
