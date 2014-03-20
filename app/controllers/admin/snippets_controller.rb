class Admin::SnippetsController < Admin::ApplicationController
  respond_to :html
  
  before_action :load_snippet, only: %i(show edit update destroy)

  breadcrumbs do |b|
    b.append Page.model_name.human(count: 2), :admin_pages
    b.append Snippet.model_name.human(count: 2), :admin_snippets
    b.append translate('breadcrumbs.new', model: Snippet.model_name.human), :new_admin_snippet if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: Snippet.model_name.human), [:edit, :admin, @snippet] if action_name.in? %w(edit update)
  end

  def index
    @snippets = Snippet.with_translations.includes(:author).sort(params[:sort], params[:direction]).page(params[:page])
    respond_with :admin, @snippets
  end

  def new
    @snippet = Snippet.new
    @snippet.translations.build(locale: I18n.locale)
    respond_with :admin, @snippet
  end

  def create
    @snippet = Snippet.create(snippet_params)
    flash_for @snippet
    respond_with :admin, @snippet, location: :admin_snippets
  end

  def show
    respond_with :admin, @snippet
  end

  def update
    @snippet.update(snippet_params)
    flash_for @snippet
    respond_with :admin, @snippet, location: :admin_snippets
  end

  def destroy
    @snippet.destroy
    flash_for @snippet
    respond_with :admin, @snippet
  end

  def destroy_multiple
    snippet_ids = Array(params[:snippet_ids])
    Snippet.destroy_all(id: snippet_ids)
    flash_for Snippet, :destroyed, multiple: true
    respond_to do |format|
      format.html { redirect_to :admin_snippets }
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @snippet = Snippet.new
    @snippet.translations.build(locale: translated_locale)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def editor_preview
    html = params[:html] || ''
    # TODO Liquidize
    respond_to do |format|
      format.html { render text: html }
    end
  end

  private
  def load_snippet
    @snippet = Snippet.find(params[:id])
  end

  def snippet_params
    params.require(:snippet).permit(translations_attributes: [:_destroy, :id, :locale, :name, :body])
  end
end