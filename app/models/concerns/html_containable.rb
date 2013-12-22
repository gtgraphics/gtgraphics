module HtmlContainable
  extend ActiveSupport::Concern

  def body_html
    template = Liquid::Template.parse(self.body)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end