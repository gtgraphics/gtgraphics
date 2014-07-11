module PanelHelper
  def panel(*args, &content)
    options = args.extract_options!.reverse_merge(body: true)
    title = args.first
    content_tag :div, class: ['panel panel-default', options[:class]].flatten.compact do
      if title.present?
        headline = content_tag(:h3, title, class: 'panel-title')
        concat content_tag(:div, headline, class: 'panel-heading')
      end
      if options[:body]
        concat content_tag(:div, class: 'panel-body', &content)
      else
        concat capture(&content)
      end
    end
  end
end