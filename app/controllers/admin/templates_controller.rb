class Admin::TemplatesController < Admin::ApplicationController
  respond_to :html

  before_action :load_template, only: %i(show edit update destroy destroy_region)

  breadcrumbs do |b|
    b.append Page.model_name.human(count: 2), :admin_pages
    b.append Template.model_name.human(count: 2), :admin_templates
    b.append translate('breadcrumbs.new', model: Template.model_name.human), :new_admin_template if action_name.in? %w(new create)
    b.append @template.name, [:admin, @template.becomes(Template)] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Template.model_name.human), [:edit, :admin, @template.becomes(Template)] if action_name.in? %w(edit update)
  end

  def index
    @templates = Template.with_translations(I18n.locale).sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @templates
  end

  def new
    @template = Template.new
    @template.translations.build(locale: I18n.locale)
    respond_with :admin, @template.becomes(Template)
  end

  def create
    @template = Template.create(template_params)
    flash_for @template
    respond_with :admin, @template.becomes(Template)
  end

  def show
    @region_definitions = @template.region_definitions.order(:label)
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

  def translation_fields
    respond_to do |format|
      format.html do
        if translated_locale = params[:translated_locale] and translated_locale.in?(I18n.available_locales.map(&:to_s))
          @template = Template.new
          @template.translations.build(locale: translated_locale)
          render layout: false
        else
          head :not_found
        end
      end
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

  private
  def load_template
    @template = Template.find(params[:id])
  end

  def template_params
    params.require(:template).permit(:type, :file_name, :region_labels, :screenshot, translations_attributes: [:_destroy, :id, :locale, :name, :description])
  end

  def template_class
    if @template_type = params[:type] and template_class = "Template::#{@template_type}" and template_class.in?(Template.template_types)
      @template_class = template_class.constantize
    else
      raise 'template type not found'
    end
  end
end