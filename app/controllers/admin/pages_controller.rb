class Admin::PagesController < Admin::ApplicationController
  layout :determine_layout

  respond_to :html

  before_action :load_page, only: %i(show edit update destroy move publish hide enable_in_menu disable_in_menu toggle_menu_item)
  before_action :load_parent_page, only: %i(index new create show edit update)
  before_action :build_page_tree

  breadcrumbs do |b|
    if @parent_page 
      @parent_page.self_and_ancestors.where.not(parent_id: nil).with_translations.each do |page|
        b.append page.title, [:admin, page]
      end
    end
    if @page
      b.append @page.title, [:admin, @page] 
      if action_name.in? %w(edit update)
        b.append translate('breadcrumbs.edit', model: Page.model_name.human), [:edit, :admin, @page]
      end
    end
  end

  def index
    respond_to do |format|
      format.html do
        # Redirect to root page
        redirect_to [:admin, Page.root]
      end
      format.json do
        if page_id_or_ids = params[:id] and page_id_or_ids.present?
          if page_id_or_ids.is_a?(Array)
            @pages = Page.where(id: page_id_or_ids)
          else
            redirect_to params.merge(action: :show) and return
          end
        else
          @pages = Page.search(params[:query])
        end
        @pages = @pages.with_translations(I18n.locale).page(params[:page])
        if assignable_id = params[:parent_assignable_id] and assignable_id.present?
          @pages = @pages.assignable_as_parent_of(assignable_id)
        end
      end
    end
  end

  def show
    @pages = @page.self_and_ancestors_and_siblings.with_translations(I18n.locale)
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json
    end
  end

  def new
    @page = Page.new
    @page.title = I18n.translate('page.default_title')
    @page.parent = @parent_page || Page.root
    @page.embeddable_type = params[:page_type] ? "Page::#{params[:page_type].strip.classify}" : 'Page::Content'
    @page.build_embeddable
    respond_to do |format|
      format.js
    end
  end

  def create
    @page = Page.new(new_page_params)
    @page.published = false
    @page.next_available_slug(@page.title.parameterize) if @page.title.present?
    @page.build_embeddable if @page.embeddable.nil?
    if @page.embeddable_type.in?(Page.embeddable_types)
      if @page.embeddable_class.supports_template?
        @page.template = @page.embeddable_class.template_class.default
      end
    end
    flash_for @page if @page.save
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_with :admin, @page
  end

  def meta
    respond_with :admin, @page
  end

  def update
    @page.update(page_params)
    flash_for @page
    respond_with :admin, @page, location: request.referer || edit_admin_page_path(@page)
  end

  def destroy
    @page.destroy
    flash_for @page
    respond_with :admin, @page, location: [:admin, @page.parent || Page.root]
  end

  def publish
    @page.publish!
    flash_for @page, :published
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def hide
    @page.hide!
    flash_for @page, :hidden
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def enable_in_menu
    @page.enable_in_menu!
    flash_for @page, :enabled_in_menu
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def disable_in_menu
    @page.disable_in_menu!
    flash_for @page, :disabled_in_menu
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def move
    valid = true
    error_message = nil
    target_page = Page.find(params[:to])
    previous_parent_id = @page.parent_id

    Page.transaction do
      # Move Page in Tree
      slug = @page.slug
      case params[:position]
      when 'inside'
        slug = slug.next while Page.without(@page).exists?(parent_id: target_page.id, slug: slug)
        @page.update_column(:slug, slug)
        @page.move_to_child_with_index(target_page, 0)
      when 'before'
        slug = slug.next while Page.without(@page).exists?(parent_id: target_page.parent_id, slug: slug)
        @page.update_column(:slug, slug)
        @page.move_to_left_of(target_page)
      when 'after'
        slug = slug.next while Page.without(@page).exists?(parent_id: target_page.parent_id, slug: slug)
        @page.update_column(:slug, slug)
        @page.move_to_right_of(target_page)
      else
        return valid = false
      end

      # Update Path
      @page.refresh_path!(true)

      # Update Counter Caches
      [@page.id, @page.parent_id, target_page.id, target_page.parent_id, previous_parent_id].compact.uniq.each do |page_id|
        Page.reset_counters(page_id, :children)
      end
    end

    respond_to do |format|
      format.html do
        if valid
          head :ok
        elsif error_message.present?
          render text: error_message, status: :unprocessable_entity
        else
          head :unprocessable_entity
        end
      end
    end
  end

  def tree
    if page_id = params[:node]
      pages = Page.find(page_id).children
    else
      pages = Page.where(depth: 0..1)
    end
    @page_tree = PageTree.new(pages.with_translations)
    respond_to do |format|
      format.json { render json: @page_tree }
    end
  end

  def preview_path
    @page = Page.new(params.symbolize_keys.slice(:slug, :parent_id))
    @page.valid?
    respond_to do |format|
      format.html { render text: @page.slug.present? ? File.join(request.host, @page.path) : '' }
    end
  end

  private
  def build_page_tree
    open_nodes = (cookies[:sitemap_state] || '').split
    conditions = [Page.arel_table[:depth].in(0..1)]
    if open_nodes.any?
      conditions << Page.arel_table[:id].in(open_nodes)
      conditions << Page.arel_table[:parent_id].in(open_nodes)
    end
    pages = Page.where(conditions.reduce(:or))
    @page_tree = PageTree.new(pages.with_translations, selected: @page)
  end

  def determine_layout
    if action_name.in? %w(new create edit update)
      'admin/page_editor'
    else
      'admin/pages'
    end
  end

  def load_page
    @page = Page.find(params[:id])
  end

  def load_parent_page
    if parent_id = params[:page_id]
      @parent_page = Page.find_by(id: parent_id)
    elsif !request.get? and page_params = params[:page]
      @parent_page = Page.find_by(id: page_params[:parent_id])
    elsif @page
      @parent_page = @page.parent
    end
  end

  def new_page_params
    page_params = params.require(:page)
    embeddable_attributes_params = case page_params[:embeddable_type]
    when 'Page::ContactForm' then { recipient_ids: [] }
    end
    page_params.permit :embeddable_type, :parent_id, :title, :parent_id,
                       embeddable_attributes: embeddable_attributes_params || []
  end

  def page_params
    page_params = params.require(:page)
    embeddable_attributes_params = case page_params[:embeddable_type]
    when 'Page::ContactForm' then [:id, :template_id, { recipient_ids: [], translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Page::Content' then [:id, :template_id, { translations_attributes: [:_destroy, :id, :locale, :title, :body] }]
    when 'Page::Homepage' then [:id, :template_id]
    when 'Page::Image' then [:id, :template_id, :asset, :image_id, :author_id, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Page::Project' then [:id, :template_id, :client_name, :client_url, :released_on, { translations_attributes: [:_destroy, :id, :locale, :name, :description] }]
    when 'Page::Redirection' then [:id, :external, :destination_page_id, :destination_url, :permanent, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    end
    page_params.permit(:title, :meta_keywords, :meta_description, :embeddable_id, :embeddable_type, :slug, :parent_id, :published, :menu_item, :indexable, embeddable_attributes: embeddable_attributes_params || []) 
  end
end