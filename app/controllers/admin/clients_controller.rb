class Admin::ClientsController < Admin::ApplicationController
  respond_to :html

  before_action :load_client, only: %i(show edit update destroy)

  def index
    @clients = Client.search(params[:query]).
                      sort(params[:sort], params[:direction]).
                      page(params[:page])
    respond_with :admin, @clients
  end

  def destroy
    respond_with :admin, @client
  end
end