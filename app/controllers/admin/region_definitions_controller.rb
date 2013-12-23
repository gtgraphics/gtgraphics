class Admin::RegionDefinitionsController < Admin::ApplicationController
  respond_to :html

  before_action :load_template
  before_action :load_region_definition, only: %i(edit update destroy)

  breadcrumbs do |b|
    b.append Template.model_name.human(count: 2), :admin_templates
    b.append @template.name, [:admin, @template.becomes(Template)] 
    b.append translate('breadcrumbs.new', model: RegionDefinition.model_name.human), [:new, :admin, @template.becomes(Template), :region_definition] if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: RegionDefinition.model_name.human), [:edit, :admin, @template.becomes(Template), @region_definition] if action_name.in? %w(edit update)
  end

  def new
    @region_definition = @template.region_definitions.new
    respond_with :admin, @template.becomes(Template), @region_definition
  end

  def create
    @region_definition = @template.region_definitions.create(region_definition_params)
    flash_for @region_definition
    respond_with :admin, @template.becomes(Template), @region_definition, location: [:admin, @template.becomes(Template), :region_definitions]
  end

  def edit
    respond_with :admin, @template.becomes(Template), @region_definition
  end

  def update
    @region_definition.update(region_definition_params)
    flash_for @region_definition
    respond_with :admin, @template.becomes(Template), @region_definition, location: [:admin, @template.becomes(Template), :region_definitions]
  end

  def destroy
    @region_definition.destroy
    flash_for @region_definition
    respond_with :admin, @template.becomes(Template), @region_definition
  end

  private
  def load_template
    @template = Template.find(params[:template_id])
  end

  def load_region_definition
    @region_definition = @template.region_definitions.find_by!(label: params[:id])
  end

  def region_definition_params
    params.require(:region_definition).permit(:label)
  end
end