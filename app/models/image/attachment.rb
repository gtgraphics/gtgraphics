# == Schema Information
#
# Table name: image_attachments
#
#  id            :integer          not null, primary key
#  image_id      :integer
#  attachment_id :integer
#  position      :integer          not null
#

class Image < ActiveRecord::Base
  class Attachment < ActiveRecord::Base
    acts_as_list scope: :image_id

    belongs_to :image, required: true, touch: true
    belongs_to :attachment, class_name: '::Attachment', required: true

    default_scope -> { order(:position) }

    delegate :title, :asset, :original_filename, :content_type, :file_extension,
             to: :attachment
  end
end

require_dependency 'image'
require_dependency 'attachment'
