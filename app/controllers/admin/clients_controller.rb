class Admin::ClientsController < Admin::ApplicationController
  respond_to :html

  before_action :load_client, only: %i(edit update)

  def index
    id = params[:id]
    if id.present?
      @client = Client.find_by(name: id) || id
      respond_to do |format|
        format.json { render :show }
      end      
    else
      query = params[:query].to_s
      @clients = Client.search(query).page(params[:page])
      @clients_with_unknown = @clients.to_a
      if query.present? and @clients_with_unknown.none? { |client| client.name.downcase == query.downcase }
        @clients_with_unknown.unshift(query)
      end
      respond_to do |format|
        format.json
      end
    end
  end

  def edit
    respond_with :admin, @client
  end

  def update
    respond_with :admin, @client
  end
end