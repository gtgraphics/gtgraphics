class RedirectionsController < ApplicationController
  respond_to :html
  
  before_action :set_redirection, only: [:show, :edit, :update, :destroy]

  def index
    @redirections = Redirection.all
    respond_with @redirections
  end

  def show
    respond_with @redirection
  end

  def new
    @redirection = Redirection.new
    respond_with @redirection
  end

  def create
    @redirection = Redirection.create(redirection_params)
    respond_with @redirection
  end

  def edit
    respond_with @redirection
  end

  def update
    @redirection.update(redirection_params)
    respond_with @redirection
  end

  def destroy
    @redirection.destroy
    respond_with @redirection
  end

  def invoke
    @redirection = Redirection.find_by_source_path!(params[:path])
    redirect_to @redirection.destination_url
  end

  private
  def set_redirection
    @redirection = Redirection.find(params[:id])
  end

  def redirection_params
    params.require(:redirection).permit(:source_path, :destination_url)
  end
end
