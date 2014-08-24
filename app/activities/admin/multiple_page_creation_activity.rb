class Admin::MultiplePageCreationActivity < Activity
  embeds_one :template
  validates :template_id, presence: true
  validates :parent_page, presence: true, strict: true
  
  attribute :published, Boolean, default: true
  
  attr_accessor :parent_page

  def pages
    @pages ||= []
  end

  protected
  def create_pages_for(page_type)
    pages.clear
    objects = self.public_send(page_type)
    Page.transaction do
      objects.each do |object|
        page = parent_page.children.public_send(page_type).new(published: published?).tap do |p|
          p.build_embeddable(template_id: template_id)
          p.embeddable.public_send("#{page_type.to_s.singularize}=", object)
          p.title = p.embeddable.to_title
          p.set_next_available_slug
          p.save!
        end
        self.pages << page
      end
    end
  end
end