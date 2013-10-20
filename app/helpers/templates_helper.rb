module TemplatesHelper
  def template_type(template)
    embeddable_types_hash = Page.template_types_hash.invert
    embeddable_types_hash[template.type].constantize.model_name.human
  end

  def template_types(representation = :singular)
    ActiveSupport::OrderedHash[*template_types_for_select(representation).flatten]
  end

  def template_types_for_select(representation = :singular)
    embeddable_types_hash = Page.template_types_hash.invert
    ::Template.template_types.collect do |template_type|
      embeddable_type = embeddable_types_hash[template_type]
      [embeddable_type.constantize.model_name.human(count: representation == :plural ? 2 : 1), template_type]
    end.sort_by(&:first)
  end
end