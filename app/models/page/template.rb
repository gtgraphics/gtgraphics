# == Schema Information
#
# Table name: page_templates
#
#  id                      :integer          not null, primary key
#  file_name               :string(255)      not null
#  name                    :string(255)
#  description             :text
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  default                 :boolean          default(FALSE), not null
#

class Page::Template < ActiveRecord::Base
  TEMPLATE_VIEWS_DIR = "pages/templates"

  has_many :pages, dependent: :nullify

  has_attached_file :screenshot, styles: { thumbnail: '75x75#', preview: '125x125' }

  validates :file_name, presence: true, uniqueness: true, inclusion: { in: ->(template) { template.class.template_files } }
  validates :name, presence: true

  before_validation :set_name
  before_save :default_current_template
  after_save :undefault_other_templates, if: :default?
  after_destroy :default_other_template, if: :default?

  default_scope -> { order(:name) }

  class << self
    def default
      where(default: true).first
    end

    def template_files
      @@template_files ||= Dir[Rails.root.join(TEMPLATE_VIEWS_DIR, '*')].collect { |filename| File.basename(filename).split('.').first }.sort
    end

    def unassigned_template_files
      template_files - pluck(:file_name)
    end
  end

  def template_path
    File.join(TEMPLATE_VIEWS_DIR, file_name)
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def to_s
    name
  end

  private
  def default_other_template
    if other_template = self.class.order(:name).first
      other_template.update_column(:default, true)
    end
  end

  def default_current_template
    self.default = true unless self.class.exists?(default: true)
  end

  def set_name
    self.name = file_name.humanize if name.blank? and file_name.present?
  end

  def undefault_other_templates
    self.class.where.not(id: id).update_all(default: false)
  end
end
