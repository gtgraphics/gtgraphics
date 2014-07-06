module Admin::MovableResourcePresenter
  extend ActiveSupport::Concern
  
  def move_up_button(options = {})
    button_options = {
      active: editable? && !object.first?,
      method: :patch,
      icon: :chevron, icon_options: { direction: :up }
    }
    button :move_up, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  def move_down_button(options = {})
    button_options = {
      active: editable? && !object.last?,
      method: :patch,
      icon: :chevron, icon_options: { direction: :down }
    }
    button :move_down, default_button_options(options).deep_merge(options.reverse_merge(button_options))
  end

  def move_up_path
    h.polymorphic_path([:move_up, :admin, object])
  end

  def move_down_path
    h.polymorphic_path([:move_down, :admin, object])
  end
end