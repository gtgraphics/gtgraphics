# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  client_id   :integer
#  author_id   :integer
#  released_in :integer
#  url         :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Project < ActiveRecord::Base
  include Ownable
  include Taggable
  include TitleSearchable
  include Translatable

  translates :title, :description, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  belongs_to :client
  has_many :project_images, class_name: 'Project::Image', inverse_of: :project, dependent: :destroy
  has_many :project_pages, class_name: 'Page::Project', inverse_of: :project, dependent: :destroy
  has_many :images, through: :project_images

  validates :title, presence: true, uniqueness: true

  before_validation :set_client, if: :client_name?

  has_owner :author, default_owner_to_current_user: false

  def client_name?
    client_name.present?
  end

  def client_name
    @client_name = client.try(:name) unless defined? @client_name
    @client_name
  end
  attr_writer :client_name

  def to_s
    title
  end

  private
  def set_client
    if client_name.blank?
      self.client = nil
    else
      self.client = Client.find_or_initialize_by(name: client_name)
    end
  end
end
