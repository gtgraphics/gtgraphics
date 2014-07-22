class Admin::TemplatesController < Admin::ApplicationController
  respond_to :html

  before_action :load_template, only: %i(show edit update destroy destroy_region move_up move_down)
  before_action :set_template_type, only: %i(index new)

  breadcrumbs do |b|
    b.append ::Template.model_name.human(count: 2), :admin_templates
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: Template.model_name.human), nil
    end
    if @template
      b.append @template.name, [:admin, @template.becomes(Template)]
      if action_name.in? %w(edit update)
        b.append translate('breadcrumbs.edit', model: Template.model_name.human), [:edit, :admin, @template.becomes(Template)]
      end
    end
  end

  def index
    if @template_type
      @templates = @template_type.constantize.order(:position)
    else
      @templates = Template.order(:name)
    end
    respond_with :admin, @templates
  end

  def new
    @template = @template_type.constantize.new
    respond_with :admin, @template
  end

  def create
    @template = Template.create(new_template_params)
    flash_for @template
    respond_with :admin, @template.becomes(Template)
  end

  def show
    @region_definitions = @template.region_definitions
    respond_with :admin, @template.becomes(Template)
  end

  def edit
    respond_with :admin, @template.becomes(Template)
  end

  def update
    @template.update(template_params)
    flash_for @template
    respond_with :admin, @template.becomes(Template)
  end

  def destroy
    if @template.destroy
      flash_for @template
    else
      flash_for :template, :destroyed, successful: false
    end
    respond_with :admin, @template.becomes(Template)
  end

  def destroy_multiple
    template_ids = Array(params[:template_ids])
    Template.destroy_all(id: template_ids)
    flash_for Template, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_templates }
    end
  end

  def destroy_region
    region_definition = @template.region_definitions.find_by!(label: params[:label])
    region_definition.destroy
    respond_to do |format|
      format.html { redirect_to [:admin, @template.becomes(::Template)] }
    end
  end

  def files_fields
    respond_to do |format|
      format.html do
        if template_type = params[:template_type] and template_type.in?(Template.template_types)
          @template = template_type.constantize.new
          render layout: false
        else
          head :not_found
        end
      end
    end
  end

  def move_up
    @template.move_higher
    respond_with :admin, @template.becomes(::Template), location: typed_admin_templates_path(template_type: @template.type.demodulize.underscore) do |format|
      format.js { @templates = @template.class.order(:position) }
    end
  end

  def move_down
    @template.move_lower
    @templates = @template.class.order(:position)
    respond_with :admin, @template.becomes(::Template), location: typed_admin_templates_path(template_type: @template.type.demodulize.underscore) do |format|
      format.js { @templates = @template.class.order(:position) }
    end
  end

  private
  def load_template
    @template = ::Template.find(params[:id])
  end

  def new_template_params
    params.require(:template).permit(:type, :name, :description, :file_name)
  end

  def template_params
    params.require(:template).permit(:name, :description, :file_name)
  end

  def template_class
    if @template_type = params[:type] and template_class = "Template::#{@template_type}" and template_class.in?(Template.template_types)
      @template_class = template_class.constantize
    else
      raise 'template type not found'
    end
  end

  def set_template_type
    @template_type = params[:template_type] ? "Template::#{params[:template_type].classify}" : nil
    @template_type = nil unless @template_type.in?(::Template.template_types)
  end
end