module ErrorHelper
  def render_base_errors(object)
    base_errors = object.errors[:base]
    if base_errors.any?
      render_flash :danger, dismissable: false do
        if base_errors.many?
          content_tag :ul do

          end
        else
          concat base_errors.first
        end
      end
    end
  end
end