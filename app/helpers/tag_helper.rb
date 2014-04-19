module TagHelper
  def tagging(tag_label)
    content_tag :span, prepend_icon(:tag, tag_label.to_s), class: 'tag'
  end

  def tagged_link_to(tag_label, url, options = {})
    css = options[:class].try(:split) || []
    css << 'tag'
    options[:class] = css.uniq.join(' ')
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