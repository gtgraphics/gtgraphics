class Admin::AlbumsController < Admin::ApplicationController
  respond_to :html

  before_action :load_album, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @albums = Album.joins(:translations).order('album_translations.title')
    respond_with :admin, @albums
  end

  def new
    @album = Album.new
    %w(en de).each do |locale|
      @album.translations.build(locale: locale)
    end
    respond_with :admin, @album
  end

  def create
    @album = Album.create(album_params)
    respond_with :admin, @album
  end

  def show
    redirect_to [:admin, @album, :images]
  end

  private
  def album_params
    params.require(:album).permit! # TODO
  end

  def load_album
    @album = Album.find_by_slug!(params[:id])
  end
end