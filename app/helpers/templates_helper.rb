module TemplatesHelper
  def template_types_for_select(representation = :singular)
    ::Template.template_classes.collect do |template_class|
      [template_class.model_name.human(count: representation == :plural ? 2 : 1), template_class.name]
    end.sort_by(&:first)
  end
end