module Admin::Image::CustomizablePresenter
  extend ActiveSupport::Concern

  def customize_button(options = {})
    button :customize, default_button_options(options).deep_merge(options.reverse_merge(active: editable?, icon: :crop, remote: true))
  end

  def customize_path
    h.polymorphic_path([:customize, :admin, object])
  end
end