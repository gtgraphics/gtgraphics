# == Schema Information
#
# Table name: templates
#
#  id          :integer          not null, primary key
#  file_name   :string(255)
#  type        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :text
#

class Template < ActiveRecord::Base
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

  attr_readonly :type

  has_many :region_definitions, autosave: true, dependent: :destroy, inverse_of: :template
  has_many :regions, through: :region_definitions

  validates :name, presence: true
  validates :type, presence: true, inclusion: { in: TEMPLATE_TYPES }, on: :create
  validates :file_name, presence: true, inclusion: { in: ->(template) { template.class.template_files }, if: :type? }
  validate :verify_region_labels_validity

  acts_as_sortable do |by|
    by.name default: true
    by.updated_at
  end

  class << self
    attr_accessor :template_lookup_path

    def default
      first!
    end

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
    @region_labels ||= TokenCollection.new(self.region_definitions.pluck(:label), unique: true)
  end
  
  def region_labels=(labels)
    @region_labels = TokenCollection.new(labels, unique: true)
    tokens = @region_labels.to_a
    tokens.each do |label|
      if self.region_definitions.none? { |region_definition| region_definition.label == label }
        self.region_definitions.build(label: label)
      end
    end
    self.region_definitions.reject { |region_definition| region_definition.label.in?(tokens) }.each(&:mark_for_destruction)
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
