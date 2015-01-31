# == Schema Information
#
# Table name: projects
#
#  id           :integer          not null, primary key
#  client_id    :integer
#  author_id    :integer
#  released_in  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  images_count :integer          default(0), not null
#

class Project < ActiveRecord::Base
  include Excludable
  include Ownable
  include PagePropagatable
  include PersistenceContextTrackable
  include Taggable
  include TitleSearchable
  include Translatable

  translates :title, :project_type, :description, :url,
             fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  belongs_to :client
  has_many :project_images, class_name: 'Project::Image', inverse_of: :project,
                            dependent: :destroy
  has_many :images, through: :project_images
  has_many :project_pages, class_name: 'Page::Project', inverse_of: :project,
                           dependent: :destroy
  has_many :pages, through: :project_pages

  validates :title, presence: true, uniqueness: true

  before_validation :set_client, if: :client_name?
  after_update :destroy_replaced_client_if_unreferenced, if: :client_id_changed?
  after_destroy :destroy_client_if_unreferenced

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

  def cover
    images.first
  end

  private

  def set_client
    if client_name.blank?
      self.client = nil
    else
      self.client = Client.find_or_initialize_by(name: client_name)
    end
  end

  def destroy_client_if_unreferenced
    client.destroy if client && client.projects.without(self).empty?
  end

  def destroy_replaced_client_if_unreferenced
    client = Client.find_by(id: client_id_was)
    client.destroy if client && client.projects.empty?
  end
end
