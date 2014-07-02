class Admin::Template::RegionDefinitionsController < Admin::ApplicationController
  before_action :load_template
  before_action :load_region_definition

  def edit
    respond_with :admin, @template, @region_definition
  end

  def update
    respond_with :admin, @template, @region_definition, location: [:admin, @template]
  end

  def move_up
    respond_with :admin, @template, @region_definition, location: [:admin, @template]
  end

  def move_down
    respond_with :admin, @template, @region_definition, location: [:admin, @template]
  end

  def destroy
    @region_definition.destroy
    respond_with :admin, @template, @region_definition, location: [:admin, @template]
  end

  private
  def load_template
    @template = Template.find(params[:template_id])
  end

  def load_region_definition
    @region_definition = @template.region_definitions.find_by!(label: params[:id])
  end
end