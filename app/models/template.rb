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

  VIEW_PATH = Rails.root.join('app/views').freeze

  translates :name, :description, fallbacks_for_empty_translations: true
  has_attached_file :screenshot, styles: { thumbnail: '75x75#', preview: '555x' }

  has_many :region_definitions, dependent: :destroy, inverse_of: :template
  has_many :pages, dependent: :destroy, inverse_of: :template

  validates :type, presence: true, inclusion: { in: ->(template) { template.class.template_types } }
  validates :file_name, presence: true, inclusion: { in: :available_template_files }

  before_save :default_current_template
  after_save :undefault_other_templates, if: :default?
  after_destroy :default_other_template, if: :default?

  scope :defaults, -> { where(default: true) }

  acts_as_batch_translatable

  Page.template_types.each do |template_type|
    scope template_type.demodulize.underscore.pluralize, -> { where(type: template_type) }

    class_eval %{
      def #{template_type.demodulize.underscore}?
        self.type == '#{template_type}'
      end
    }
  end

  class << self
    attr_accessor :template_lookup_path

    def default
      defaults.first
    end

    def template_types
      Page.template_types
    end

    def template_files
      raise 'no lookup path defined' if template_lookup_path.nil?
      @template_files ||= Dir[File.join(VIEW_PATH, template_lookup_path, '*')].map { |template_file| File.basename(template_file).split('.').first }.sort
    end

    def unassigned_template_files
      template_files - pluck(:file_name)
    end
  end

  def description_html
    (description || '').html_safe
  end

  def view_path
    raise 'no lookup path defined' if self.class.template_lookup_path.nil?
    raise 'no template file defined' if file_name.nil?
    @view_path ||= File.join(self.class.template_lookup_path, file_name)
  end

  private
  def available_template_files
    if type.present?
      type.constantize.template_files
    else
      []
    end
  end

  def default_current_template
    self.default = true unless self.class.exists?(default: true)
  end

  def default_other_template
    if other_template = self.class.first
      other_template.update_column(:default, true)
    end
  end

  def undefault_other_templates
    self.class.where.not(id: id).update_all(default: false)
  end
end
