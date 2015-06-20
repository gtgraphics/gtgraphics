module TitleHelper
  SEPARATOR = ' &middot; '

  def page_title
    if content_for?(:title)
      elements = [content_for(:title)]
    else
      elements = breadcrumbs.collect(&:caption).drop(1).reverse
    end
    elements << translate('views.title')
    elements.compact!
    elements.join(SEPARATOR).html_safe
  end
end
