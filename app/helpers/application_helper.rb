module ApplicationHelper
  def admin_context?
    signed_in? or controller.class.name.split('::').first == 'Admin'
  end

  def available_locales_for_select
    I18n.available_locales.map { |locale| [translate(locale, scope: :languages), locale] }.sort_by(&:first)
  end
  
  def microtimestamp
    (Time.now.to_f * 1_000_000).to_i
  end
end
