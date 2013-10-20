module PagesHelper
  def page_types_for_select(representation = :singular)
    Page.embeddable_types.collect do |embeddable_type|
      [embeddable_type.constantize.model_name.human(count: representation == :plural ? 2 : 1), embeddable_type]
    end.sort_by(&:first)
  end
end