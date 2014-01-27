module Admin::ToolbarHelper
  def toolbar(options = {}, &block)
    capture_haml do
      haml_tag '.gtg-admin-toolbar', options do
        haml_tag '.container', id: 'toolbar' do
          haml_concat render('breadcrumbs', toolbar: true)
          haml_tag '.btn-toolbar', class: 'pull-right', &block if block_given?
        end
      end
    end
  end
end