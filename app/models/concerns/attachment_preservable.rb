module AttachmentPreservable
  extend ActiveSupport::Concern

  OPTIONS = {
    temp_dir: Rails.root.join('public', 'system', 'tmp'),
    preserve_for: 1.day
  }.freeze

  class << self
    def options
      OPTIONS
    end

    # Sweep files in temp folder that have not been changed for a while
    def sweep!
      options = AttachmentPreservable.options
      Dir[File.join(options[:temp_dir], '*')].each do |file|
        File.unlink(file) if File.ctime(file) < options[:preserve_for].ago
      end
    end
  end

  included do
    #after_validation :preserve_uploaded_assets, if: :preserve_uploaded_assets?
    after_validation :preserve_attachments, if: :preserve_attachments?
  end

  module ClassMethods
    def preserved_attachment_attributes
      @preserved_attachment_attributes ||= []
    end

    def preserve_attachment_between_requests_for(*attachment_methods)
      attachment_methods.each do |attachment_method|
        next unless self.method_defined?(attachment_method)

        self.preserved_attachment_attributes << attachment_method
        %w(file_name file_size content_type updated_at).each do |suffix|
          attr_accessor :"temp_#{attachment_method}_#{suffix}"
        end
      end
      self.preserved_attachment_attributes.uniq!
    end
  end

  def preserve_attachments!
    @preserve_attachments = true
  end

  def preserve_attachments?
    @preserve_attachments ||= false
  end

  private
  def preserve_attachments
    attachment_methods = self.class.preserved_attachment_attributes
    attachment_methods.each do |attachment_method|
      # TODO
    end
  end

  def preserve_uploaded_assets
    if errors.any?
      # create Tempdir if it does not exist
      FileUtils.makedirs(Attachment.temp_store_dir)

      attachments.each do |attachment|
        # Only temporarily save the file if the specific asset did not cause any validation errors
        if attachment.errors[:concrete_attachment].blank?
          # Save an asset in the temp folder if it has been set
          if attachment.asset?
            # If the asset has only changed (asset has been set in the last request), remove the old tempfile
            FileUtils.rm_r(File.dirname(attachment.temp_asset_path), force: true) if attachment.temp_asset?

            # Retrieve the newly set asset file
            asset_to_create = attachment.asset.queued_for_write[:original]
            if asset_to_create
              # Store uploaded file data temporarily so that it can be reused within hidden fields of the form
              attachment.temp_asset_file_name = File.join(SecureRandom.uuid, File.basename(attachment.asset.original_filename))
              attachment.temp_asset_file_size = attachment.asset.size
              attachment.temp_asset_content_type = attachment.asset.content_type

              # Move Paperclip tempfile so that it is publicly accessible (e.g. for embedded preview)
              FileUtils.mkdir(File.dirname(attachment.temp_asset_path))
              FileUtils.move(asset_to_create.path, attachment.temp_asset_path)
            end
          end

          # Load the tempfile to Paperclip so you can work on it like on a normal Paperclip object
          if attachment.temp_asset?
            attachment.asset_content_type = attachment.temp_asset_content_type
            attachment.asset_file_size = attachment.temp_asset_file_size
            File.open(attachment.temp_asset_path) do |tempfile|
              attachment.asset = tempfile
            end
          end
        else
          # Model is not valid due to the current attachment, so remove tempfile as it is invalid
          FileUtils.rm_r(File.dirname(attachment.temp_asset_path), force: true)
          attachment.temp_asset_file_name = nil
          attachment.temp_asset_content_type = nil
          attachment.temp_asset_file_size = nil
          attachment.asset = nil
        end
      end
    else
      # Model is valid, so save each attachment asset and remove tempfiles
      attachments.each do |attachment|
        if attachment.temp_asset?
          # Only load tempfile to asset if it has not been set by user
          unless attachment.asset?
            attachment.asset_content_type = attachment.temp_asset_content_type
            attachment.asset_file_size = attachment.temp_asset_file_size
            File.open(attachment.temp_asset_path) do |tempfile|
              attachment.asset = tempfile
            end
          end

          # If there is a tempfile, remove it and the containing folder
          FileUtils.rm_r(File.dirname(attachment.temp_asset_path), force: true)
        end
      end
    end
  end
end