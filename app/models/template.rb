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

  VIEW_PATH = Rails.root.join('app/views').freeze

  translates :name, :description, fallbacks_for_empty_translations: true

  has_attached_file :screenshot, styles: { thumbnail: '75x75#', preview: '555x' }, url: '/system/templates/screenshots/:id/:style.:extension'

  acts_as_batch_translatable
  acts_as_html_containable :description

  has_many :region_definitions, dependent: :destroy, inverse_of: :template
  has_many :pages, dependent: :destroy, inverse_of: :template

  validates :file_name, presence: true, inclusion: { in: -> { self.class.unassigned_template_files } }

  class << self
    def grouped_template_files
      template_files.group_by { |template_file| File.join(template_file.split('/')[0..-2]) }
    end

    def template_lookup_paths
      @template_lookup_paths ||= %w(templates)
    end
    attr_writer :template_lookup_paths

    def template_files(full_paths = false)
      template_lookup_paths = Array(self.template_lookup_paths)
      if template_lookup_paths.one?
        template_lookup_paths = self.template_lookup_paths.first
      else
        template_lookup_paths = "{#{self.template_lookup_paths.join(',')}}"
      end
      Dir[File.join([VIEW_PATH, template_lookup_paths, '*'].compact)].map do |template_file|
        if full_paths
          template_fileruf
        else
          dirname = File.dirname(template_file.gsub("#{VIEW_PATH}/", ''))
          basename = File.basename(template_file).split('.').first
          "#{dirname}/#{basename}"          
        end
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
