module PanelHelper
  def panel(*args, &content)
    options = args.extract_options!
    title = args.first
    content_tag :div, class: 'panel panel-default' do
      if title.present?
        headline = content_tag(:h3, title, class: 'panel-title')
        concat content_tag(:div, headline, class: 'panel-heading')
      end
      concat content_tag(:div, class: 'panel-body', &content)
    end
  end
end