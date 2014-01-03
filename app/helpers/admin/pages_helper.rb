module Admin::PagesHelper
  def page_types_for_select(representation = :singular)
    Page.creatable_embeddable_classes.collect do |embeddable_class|
      [embeddable_class.model_name.human(count: representation == :plural ? 2 : 1), embeddable_class.name]
    end.sort_by(&:first)
  end
end