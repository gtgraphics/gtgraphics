module PagesHelper
  def render_region
    (@page.render_region || '').html_safe
  end
end