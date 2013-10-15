module PagesHelper
  def page_path(page, options = {})
    super(page.path, options)
  end

  def page_url(page, options = {})
    super(page.path, options)
  end
end