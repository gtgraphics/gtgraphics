class Admin::ShoutsController < Admin::ApplicationController
  respond_to :html

  before_action :load_shout, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @shouts = Shout.order(:created_at).reverse_order
    respond_with @shouts
  end

  def new
    @shout = Shout.new
    respond_with @shout
  end

  def create
    @shout = Shout.new(shout_params)
    @shout.ip = request.ip
    @shout.user_agent = request.user_agent
    @shout.save
    respond_with :admin, @shout, location: :admin_shouts
  end

  def show
    respond_with :admin, @shout
  end

  def edit
    respond_with :admin, @shout
  end

  def update
    @shout.update(shout_params)
    respond_with :admin, @shout, location: :admin_shouts
  end

  def destroy
    @shout.destroy
    respond_with :admin, @shout
  end

  private
  def load_shout
    @shout = Shout.find(params[:id])
  end

  def shout_params
    params.require(:shout).permit(:nickname, :message, :x, :y)
  end
end