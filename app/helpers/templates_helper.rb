module TemplatesHelper
  def template_types_for_select
    template_types.map do |template_class|
      [template_class.model_name.human, template_class.name]
    end
  end

  def template_types
    ::Template.template_classes.sort_by { |template_class| template_class.model_name.human }
  end
end