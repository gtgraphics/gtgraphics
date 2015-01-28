module ApplicationHelper
  def admin_controller?
    controller.class.name.split('::').first == 'Admin'
  end

  def body_css
    classes = ['gtgraphics', I18n.locale.to_s]
    classes << 'admin' if admin_controller?
    classes << controller_name.dasherize
    classes << "#{controller_name.dasherize}-#{action_name.dasherize}"
    classes << "template-#{@page.template.file_name}" if page.support_templates?
    classes << content_for(:body_css).presence
    classes.compact.flatten
  end

  def body_styles
    styles = Array(content_for(:body_styles).presence)
    styles.compact.flatten.map { |style| style.gsub(';', '') }.join('; ')
  end

  def microtimestamp
    (Time.now.to_f * 1_000_000).to_i
  end

  def controller_namespace
    controller.class.name.deconstantize.underscore.presence
  end
end
