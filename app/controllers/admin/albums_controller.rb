class Admin::AlbumsController < Admin::ApplicationController
  respond_to :html

  before_action :load_album, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @albums = Album.all
    respond_with @albums
  end

  def new
    @album = Album.new
    respond_with @album
  end

  def create
    @album = Album.create(album_params)
    respond_with @album
  end

  private
  def album_params
    params.require(:album).permit! # TODO
  end

  def load_album
    @album = Album.find_by_slug(params[:id])
  end
end