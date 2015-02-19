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
#  position    :integer          not null
#

class Template < ActiveRecord::Base
  include ConcreteTemplate
  include Excludable
  include PersistenceContextTrackable

  TEMPLATE_TYPES = %w(
    Template::ContactForm
    Template::Content
    Template::Homepage
    Template::Image
    Template::Project
  ).freeze

  VIEW_ROOT = "#{Rails.root}/app/views"

  attr_readonly :type

  has_many :region_definitions, dependent: :destroy, inverse_of: :template
  has_many :regions, through: :region_definitions

  validates :name, presence: true
  validates :type, presence: true,
                   inclusion: { in: TEMPLATE_TYPES, allow_blank: true },
                   on: :create
  validates :file_name, presence: true, inclusion: {
    in: ->(template) { template.class.template_files },
    if: :type?, allow_blank: true
  }

  class_attribute :template_lookup_path, instance_accessor: false

  class << self
    def template_files(full_paths = false)
      if name == 'Template'
        fail 'method can only be called on subclasses of Template'
      end
      lookup_path = File.join([VIEW_ROOT, template_lookup_path, '*'].compact)
      Dir.glob(lookup_path).map do |template_file|
        if full_paths
          template_file
        else
          File.basename(template_file).gsub(/\.(.*)\z/, '')
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

  alias_attribute :filename, :file_name

  private

  def verify_region_labels_validity
    return if region_definitions.none? { |rd| rd.errors.any? }
    errors.add(:region_labels, :contains_invalid)
  end
end
