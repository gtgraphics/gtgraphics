module Admin::ToolbarHelper
  def toolbar(options = {}, &block)
    capture_haml do
      haml_tag '.gtg-admin-toolbar', options do
        haml_tag '.container', id: 'toolbar' do
          haml_tag '.page-header' do
            haml_tag :h1, breadcrumbs.last
          end
          haml_tag '.btn-toolbar', class: 'pull-right', &block if block_given?
        end
      end
    end
  end
end