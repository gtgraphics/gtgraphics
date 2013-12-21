module FlashHelper
  def render_flash(message, options = {})
    return if message.blank?
    
    alert_type = options.delete(:type)
    dismissable = options.delete(:dismissable) { false }
    
    options[:class] ||= ''
    options[:class] << " alert alert-#{alert_type}"
    options[:class] << ' alert-dismissable' if dismissable
    options[:class].strip!

    content_tag :div, options do
      if dismissable
        inner_html = String.new.html_safe
        inner_html << button_tag(icon(:times), name: nil, type: 'button', class: 'close', data: { dismiss: 'alert' }, 'aria-hidden' => true)
        inner_html << message
      else
        message
      end
    end
  end
end