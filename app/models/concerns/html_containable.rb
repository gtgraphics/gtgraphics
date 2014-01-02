module HtmlContainable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_html_containable(*attributes)
      attributes.each do |attribute|
        class_eval %{
          def #{attribute}_html
            template = Liquid::Template.parse(self.#{attribute})
            template.render(to_liquid).html_safe
          end
        }
      end
    end
  end
end