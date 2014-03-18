# == Schema Information
#
# Table name: templates
#
#  id                      :integer          not null, primary key
#  file_name               :string(255)
#  type                    :string(255)
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime
#

class Template < ActiveRecord::Base
  include BatchTranslatable
  include ConcreteTemplate
  include Excludable
  include PersistenceContextTrackable
  include Sortable

  TEMPLATE_TYPES = %w(
    Template::ContactForm
    Template::Content
    Template::Homepage
    Template::Image
    Template::Project
  ).freeze

  VIEW_ROOT = "#{Rails.root}/app/views"

  translates :name, :description, fallbacks_for_empty_translations: true

  has_attached_file :screenshot, styles: { thumbnail: '75x75#', preview: '555x' }, url: '/system/templates/screenshots/:id/:style.:extension'

  acts_as_batch_translatable
  acts_as_sortable do |by|
    by.name(default: true) { |column, dir| Template::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end

  has_many :region_definitions, autosave: true, dependent: :destroy, inverse_of: :template
  has_many :regions, through: :region_definitions

  validates :type, presence: true, inclusion: { in: TEMPLATE_TYPES }, on: :create
  validates :file_name, presence: true, inclusion: { in: ->(template) { template.class.template_files }, if: :type? }
  validate :verify_region_labels_validity

  attr_readonly :type

  class << self
    attr_accessor :template_lookup_path

    def template_files(full_paths = false)
      raise 'method can only be called on subclasses of Template' if self.name == 'Template'
      Dir[File.join([VIEW_ROOT, template_lookup_path, '*'].compact)].map do |template_file|
        if full_paths
          template_file
        else
          File.basename(template_file).split('.').first
        end
      end.sort.freeze
    end

    def template_classes
      TEMPLATE_TYPES.map(&:constantize).freeze
    end

    def template_types
      TEMPLATE_TYPES
    end
  end

  def region_labels
    @region_labels ||= TokenCollection.new(region_definitions.pluck(:label), sort: true)
  end
  
  def region_labels=(labels)
    @region_labels = TokenCollection.new(labels, sort: true, unique: true)
    tokens = @region_labels.tokens
    tokens.each do |label|
      if region_definitions.none? { |region_definition| region_definition.label == label }
        region_definitions.build(label: label)
      end
    end
    region_definitions.reject { |region_definition| tokens.include?(region_definition.label) }.each(&:mark_for_destruction)
  end

  def view_path
    raise 'no template file defined' if file_name.blank?
    File.join(self.class.template_lookup_path, file_name)
  end

  private
  def verify_region_labels_validity
    if region_definitions.any? { |region_definition| region_definition.errors.any? }
      errors.add(:region_labels, :contains_invalid)
    end
  end
end
