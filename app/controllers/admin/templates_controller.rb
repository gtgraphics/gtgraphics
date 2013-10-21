class Admin::TemplatesController < Admin::ApplicationController
  respond_to :html

  before_action :load_template, only: %i(show edit update destroy make_default)

  breadcrumbs do |b|
    b.append Template.model_name.human(count: 2), :admin_templates
    b.append translate('breadcrumbs.new', model: Template.model_name.human), :new_admin_template if action_name.in? %w(new create)
    b.append @template.name, [:admin, @template.becomes(Template)] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Template.model_name.human), [:edit, :admin, @template.becomes(Template)] if action_name.in? %w(edit update)
  end

  def index
    @templates = template_class.with_translations
    respond_with :admin, @templates
  end

  def new
    @template = template_class.new
    @template.translations.build(locale: I18n.locale)
    respond_with :admin, @template.becomes(Template)
  end

  def create
    @template = Template.create(template_params)
    respond_with :admin, @template.becomes(Template)
  end

  def show
    respond_with :admin, @template.becomes(Template)
  end

  def edit
    respond_with :admin, @template.becomes(Template)
  end

  def update
    @template.update(template_params)
    respond_with :admin, @template.becomes(Template)
  end

  def destroy
    @template.destroy
    respond_with :admin, @template.becomes(Template)
  end

  def make_default
    @template.update(default: true)
    redirect_to :admin_templates
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

  def unassigned_files_fields
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
    params.require(:template).permit(:type, :file_name, :default, translations_attributes: [:_destroy, :id, :locale, :name, :description])
  end

  def template_class
    if @template_type = params[:type] and template_class = "Template::#{@template_type.camelize}" and template_class.in?(Template.template_types)
      @template_class = template_class.constantize
      @template_class
    else
      Template
    end
  end
end