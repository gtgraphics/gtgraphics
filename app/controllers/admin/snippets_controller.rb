class Admin::SnippetsController < Admin::ApplicationController
  before_action :load_snippet, only: %i(show edit update destroy)

  def index
    @snippets = Snippet.all
    respond_with :admin, @snippets
  end

  def new
    @snippet = Snippet.new
    respond_with :admin, @snippet
  end

  def create
    @snippet = Snippet.create(snippet_params)
    flash_for @snippet, :created
    respond_with :admin, @snippet
  end

  def show
    respond_with :admin, @snippet
  end

  def update
    @snippet.update(snippet_params)
    flash_for @snippet
    respond_with :admin, @snippet
  end

  def destroy
    @snippet.destroy
    flash_for @snippet
    respond_with :admin, @snippet
  end

  private
  def load_snippet
    @snippet = Snippet.find(params[:id])
  end

  def snippet_params
    params.require(:snippet).permit! # TODO
  end
end