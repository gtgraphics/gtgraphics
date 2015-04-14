class ImageUploader < AttachmentUploader
  include ImageUploadable

  version :public, from_version: :custom do
    process quality: 85

    def full_filename(file)
      "public/#{file}"
    end
  end

  version :social, from_version: :custom do
    process resize_to_fill: [500, 500]
    process quality: 85

    def full_filename(file)
      "social/#{file}"
    end
  end

  version :brick, from_version: :custom do
    process resize_to_fit: [354, 100_000] # OPTIMIZE: this is a freakin' hotfix
    process quality: 85

    def full_filename(file)
      "bricks/#{file}"
    end
  end

  version :menu_brick, from_version: :custom do
    process resize_to_fill: [530, 200]
    process quality: 85

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
