class Admin::ProjectPageCreationActivity < Activity
  include Tokenizable

  embeds_many :projects
  embeds_one :template

  attribute :published, Boolean, default: true

  validates :project_ids, :project_id_tokens, presence: true
  validates :template_id, presence: true
  validates :parent_page, presence: true, strict: true

  tokenizes :project_ids

  attr_accessor :parent_page

  def pages
    @pages ||= []
  end

  def perform
    self.pages.clear
    Page.transaction do
      project_ids.each do |image_id|
        self.pages << parent_page.children.projects.new(published: published?).tap do |p|
          p.build_embeddable(image_id: image_id, template_id: template_id)
          p.title = p.embeddable.to_title
          p.set_next_available_slug
          p.save!
        end
      end
    end
  end
end