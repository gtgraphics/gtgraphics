module TitleHelper
  def page_title
    if content_for? :title
      content_for :title
    else
      ([translate('views.title')] + breadcrumbs.collect(&:caption).drop(1))
        .reverse.join(' &middot; ').html_safe
    end
  end
end
