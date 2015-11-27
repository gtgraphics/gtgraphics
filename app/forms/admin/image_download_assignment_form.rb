module Admin
  class ImageDownloadAssignmentForm < Form
    embeds_many :attachments

    attr_accessor :image

    validates :image, presence: true, strict: true
    validates :attachment_ids, presence: true

    def perform
      attachments.each do |attachment|
        image.downloads.build(attachment: attachment)
      end
      image.save!
    end
  end
end
