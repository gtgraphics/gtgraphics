class Admin::Template::RegionDefinitionsController < Admin::ApplicationController
  respond_to :html, :js

  before_action :load_template
  before_action :load_region_definition, except: %i(new create)

  def new
    @region_definition = @template.region_definitions.new
    respond_with :admin, abstract_template, @region_definition
  end

  def create
    @region_definition = @template.region_definitions.create(region_definition_params)
    respond_with :admin, abstract_template, @region_definition
  end

  def edit
    respond_with :admin, abstract_template, @region_definition
  end

  def update
    @region_definition.update(region_definition_params)
    respond_with :admin, abstract_template, @region_definition, location: [:admin, abstract_template]
  end

  def move_up
    @region_definition.move_higher
    respond_with :admin, abstract_template, @region_definition, location: [:admin, abstract_template]
  end

  def move_down
    @region_definition.move_lower
    respond_with :admin, abstract_template, @region_definition, location: [:admin, abstract_template]
  end

  def destroy
    @region_definition.destroy
    respond_with :admin, abstract_template, @region_definition, location: [:admin, abstract_template]
  end

  private
  def abstract_template
    @template.becomes(::Template)
  end

  def load_template
    @template = ::Template.find(params[:template_id])
  end

  def load_region_definition
    @region_definition = @template.region_definitions.find_by!(label: params[:id])
  end

  def region_definition_params
    params.require(:template_region_definition).permit(:name, :label)
  end
end