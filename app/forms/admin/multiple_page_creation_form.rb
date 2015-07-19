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

    object_ids = public_send("#{page_type.to_s.singularize}_ids")
    objects = public_send(page_type).to_a

    Page.transaction do
      object_ids.each_with_index do |object_id, index|
        # preserves order
        object = objects.find { |obj| obj.id == object_id }

        page = parent_page.children.public_send(page_type).new
        page.build_embeddable(template_id: template_id)
        page.embeddable.public_send("#{page_type.to_s.singularize}=", object)
        page.published = published?
        page.title = page.embeddable.to_title

        if object.respond_to?(:translations)
          object.translations.each do |translation|
            Globalize.with_locale(translation.locale) do
              page.meta_description = Rails::Html::FullSanitizer.new.sanitize(
                translation.description
              )
            end
          end
        end

        page.set_next_available_slug
        page.save!
        page.move_to_child_with_index(parent_page.reload, index) if parent_page

        pages << page
      end
    end
  end
end
