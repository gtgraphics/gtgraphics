class Admin::MultiplePageCreationForm < Form
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

    object_ids = self.public_send("#{page_type.to_s.singularize}_ids")
    objects = self.public_send(page_type).to_a

    Page.transaction do
      object_ids.each_with_index do |object_id, index|
        object = objects.detect { |object| object.id == object_id } # preserves order

        p object
        puts '#########################################'

        page = parent_page.children.public_send(page_type).new
        page.build_embeddable(template_id: template_id)
        page.embeddable.public_send("#{page_type.to_s.singularize}=", object)
        page.published = published?
        page.title = page.embeddable.to_title
        page.set_next_available_slug
        page.save!
        page.move_to_child_with_index(parent_page.reload, index) if parent_page

        self.pages << page
      end
    end
  end
end