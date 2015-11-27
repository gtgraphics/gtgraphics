module Admin
  class ImageDownloadAssignmentForm < Form
    embeds_many :attachments

    attr_accessor :image

    def attachment_ids=(attachment_ids)
      if attachment_ids.is_a?(String)
        attachment_ids = attachment_ids.split(',')
                         .map(&:to_i).reject(&:zero?)
      end
      super(attachment_ids)
    end

    validates :image, presence: true, strict: true
    validates :attachment_ids, presence: true

    def perform
      ::Image::Download.transaction do
        attachment_ids.each do |attachment_id|
          image.downloads.create!(attachment_id: attachment_id)
        end
      end
    end
  end
end
