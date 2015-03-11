class Image::StyleUploader < AttachmentUploader
  include ImageUploadable

  version :public, from_version: :custom do
    process convert: 'jpeg'
    process quality: 85

    def filename
      super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
    end

    def full_filename(file)
      file = file.chomp(File.extname(file)) + '.jpg'
      "public/#{file}"
    end
  end

  def store_dir
    "system/images/styles/#{model.image.asset_token}"
  end

  def cache_dir
    'tmp/uploads/images/styles'
  end
end
