module TagHelper
  def tagging(tag_label, options = {})
    options.assert_valid_keys(:size)
    size = options[:size]
    size = "tag-#{size}" if size.present?
    content_tag :span, prepend_icon(:tag, tag_label.to_s), class: "tag #{size}".strip, title: tab_label.to_s
  end

  def tagged_link_to(tag_label, url, options = {})
    size = options.delete(:size)
    css = options[:class].try(:split) || []
    css << 'tag'
    css << "tag-#{size}" if size.present?
    options[:class] = css.uniq.join(' ')
    options[:title] ||= tag_label.to_s
    link_to prepend_icon(:tag, tag_label.to_s), url, options
  end

  def tagged_link_to_if(condition, tag_label, *args)
    if condition
      tagged_link_to(tag_label, *args)
    else
      tagging(tag_label)
    end
  end

  def tagged_link_to_unless(condition, *args)
    tagged_link_to_if(!condition, *args)
  end
end