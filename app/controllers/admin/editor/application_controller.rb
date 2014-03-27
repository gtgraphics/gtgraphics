class Admin::Editor::ApplicationController < Admin::ApplicationController
  layout 'modal'

  def self.editor_actions_for(name, options = {})
    class_name = options.fetch(:class_name, "::Editor::#{name.to_s.classify}")

    attr_reader name
    private name
    helper_method name

    class_eval %{
      def show
        @#{name} = #{class_name}.from_html(params[:html])
        respond_to do |format|
          format.html
        end
      end

      def create
        @#{name} = ::Editor::Image.new(#{name}_params)
        valid = @#{name}.valid?
        respond_to do |format|
          format.html do
            if valid
              render text: @#{name}.to_html, layout: false
            else
              render :show, layout: false, status: :unprocessable_entity
            end
          end
        end
      end

      def #{name}_params
        params.require(:editor_#{name}).permit!
      end
      private :#{name}_params
    }
  end
end