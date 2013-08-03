module ButtonHelper
  def active_button_link_to(*args, &block)
    extract_button_options!(args)
    active_link_to *args, &block
  end

  def button_link_to(*args, &block)
    extract_button_options!(args)
    link_to *args, &block
  end

  def button_link_to_if(condition, *args, &block)
    extract_button_options!(args)
    link_to_if condition, *args, &block
  end

  def button_link_to_unless(condition, *args, &block)
    extract_button_options!(args)
    link_to_unless condition, *args, &block
  end

  private
  def extract_button_options!(args)
    options = args.extract_options!.dup
    
    type = options.delete(:as)
    other_type = options.delete(:type)
    type ||= other_type
    type ||= 'default'
    icon = options.delete(:icon)
    size = options.delete(:size)
    block_rendering = options.delete(:block)

    css = options.delete(:class).to_s + " btn"
    css << " btn-#{type}" if type
    css << " btn-#{size}" if size
    css << " btn-block" if block_rendering
    options[:class] = css.strip

    args << options
  end
end