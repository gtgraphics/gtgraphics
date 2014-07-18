class ImageUploader < AttachmentUploader
  include ImageUploadable

  version :social, from_version: :custom do
    process resize_to_fill: [500, 500]

    def full_filename(file)
      "social/#{file}"
    end
  end

  def store_dir
    'system/images'
  end

  def cache_dir
    'tmp/uploads/images'
  end
end