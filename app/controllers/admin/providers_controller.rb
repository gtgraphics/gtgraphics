class Admin::ProvidersController < Admin::ApplicationController
  respond_to :html

  before_action :load_provider, only: %i(edit update destroy)

  authorize_resource

  breadcrumbs do |b|
    b.append Provider.model_name.human(count: 2), :admin_providers
    b.append translate('breadcrumbs.new', model: Provider.model_name.human),
             :new_admin_provider if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: Provider.model_name.human),
             [:edit, :admin, @provider] if action_name.in? %w(edit update)
  end

  def index
    @providers = Provider.order(:name)

    respond_with :admin, @providers
  end

  def new
    @provider = Provider.new

    respond_with :admin, @provider
  end

  def create
    @provider = Provider.create(provider_params)

    respond_with :admin, @provider, location: :admin_providers
  end

  def edit
    respond_with :admin, @provider
  end

  def update
    @provider.update(provider_params)

    respond_with :admin, @provider, location: :admin_providers
  end

  def destroy
    @provider.destroy

    respond_with :admin, @provider
  end

  private

  def load_provider
    @provider = Provider.find(params[:id])
  end

  def provider_params
    params.require(:provider).permit(:name, :logo)
  end
end
