class Admin::Editor::ApplicationController < Admin::ApplicationController
  layout 'modal'

  def self.editor_actions_for(name, options = {})
    class_name = options.fetch(:class_name, "::Editor::#{name.to_s.classify}")
    permitted_params = Array(options[:params])

    attr_reader name
    private name
    helper_method name

    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def show
        editor_params = Hash(params[:editor]).slice(*#{permitted_params.inspect})
        @#{name} = #{class_name}.new(editor_params)
        respond_to do |format|
          format.html
        end
      end

      def new
        show
      end

      def create
        @#{name} = #{class_name}.new(#{name}_params)
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

      def edit
        show
      end

      def update
        create
      end

      def #{name}_params
        permitted_params = #{permitted_params.inspect}
        editor_params = params.require(:editor_#{name})
        if permitted_params.empty?
          editor_params.permit!
        else
          editor_params.permit(*permitted_params)
        end
      end
      protected :#{name}_params
    RUBY
  end
end