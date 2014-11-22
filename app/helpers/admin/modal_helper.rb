module Admin::ModalHelper
  def modal(file, layout = :modal)
    escape_javascript render(file: file, layout: "layouts/#{layout}", formats: [:html])
  end
end