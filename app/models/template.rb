# == Schema Information
#
# Table name: templates
#
#  id                      :integer          not null, primary key
#  file_name               :string(255)
#  type                    :string(255)
#  default                 :boolean          default(FALSE), not null
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime
#

class Template < ActiveRecord::Base
  include BatchTranslatable
  include HtmlContainable
  include PersistenceContextTrackable

  VIEW_PATH = Rails.root.join('app/views/templates').freeze

  translates :name, :description, fallbacks_for_empty_translations: true

  has_attached_file :screenshot, styles: { thumbnail: '75x75#', preview: '555x' }, url: '/system/templates/screenshots/:id/:style.:extension'

  acts_as_batch_translatable
  acts_as_html_containable :description

  has_many :region_definitions, dependent: :destroy, inverse_of: :template
  has_many :pages, dependent: :destroy, inverse_of: :template

  validates :file_name, presence: true, inclusion: { in: -> { self.class.unassigned_template_files } }

  class << self
    def template_files
      @@template_files ||= Dir[File.join(VIEW_PATH, '*')].map do |template_file|
        File.basename(template_file).split('.').first
      end.sort.freeze
    end

    def unassigned_template_files
      (template_files - pluck(:file_name)).freeze
    end

    def without(template)
      if template.new_record?
        all
      else
        where.not(id: template.id)
      end
    end
  end

  def view_path
    raise 'no template file defined' if file_name.blank?
    view_path = File.join(VIEW_PATH, file_name)
    raise MissingFile.new(self) unless File.exists?(view_path)
    view_path
  end
end
