class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit edit_metadata update destroy move
                                     publish hide enable_in_menu disable_in_menu
                                     toggle_menu_item change_template)
  before_action :load_parent_page, only: %i(index new create show edit update)
  before_action :build_page_tree

  helper_method :available_templates

  breadcrumbs do |b|
    if @parent_page
      pages = @parent_page.self_and_ancestors.where.not(parent_id: nil)
              .with_translations_for_current_locale
      pages.each do |page|
        b.append page.title, [:admin, page]
      end
    end
    if @page
      b.append @page.title, [:admin, @page]
      if action_name.in? %w(edit update)
        b.append translate('breadcrumbs.edit', model: Page.model_name.human),
                 [:edit, :admin, @page]
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
        page_id_or_ids = params[:id]
        if page_id_or_ids && page_id_or_ids.present?
          if page_id_or_ids.is_a?(Array)
            @pages = Page.where(id: page_id_or_ids)
          else
            redirect_to params.merge(action: :show)
            return
          end
        else
          @pages = Page.search(params[:query])
        end
        @pages = @pages.with_translations_for_current_locale.page(params[:page])
        assignable_id = params[:parent_assignable_id]
        if assignable_id.present?
          @pages = @pages.assignable_as_parent_of(assignable_id)
        end
      end
    end
  end

  def tree
    page_id = params[:node]
    if page_id
      pages = Page.find(page_id).children
    else
      pages = Page.where(depth: 0..1)
    end
    @page_tree = Admin::PageTree.new(pages.with_translations_for_current_locale)
    respond_to do |format|
      format.json { render json: @page_tree }
    end
  end

  def autocomplete
    query = params[:query]
    if query.present?
      @pages = Page.search(query).with_translations_for_current_locale
               .uniq.limit(3)
    else
      @pages = Page.none
    end
    respond_to do |format|
      format.json { render :index }
    end
  end

  def show
    respond_to do |format|
      format.html { render layout: !request.xhr? }
      format.json
    end
  end

  def new
    @page = Page.new do |p|
      p.title = I18n.translate('page.default_title')
      p.parent = @parent_page || Page.root
      if params[:page_type]
        p.embeddable_type = "Page::#{params[:page_type].strip.classify}"
      else
        p.embeddable_type = 'Page::Content'
      end
      p.build_embeddable
      if p.support_templates? && p.embeddable_type.in?(Page.embeddable_types)
        p.template = p.template_class.default
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    Page.transaction do
      @page = Page.create(new_page_params) do |p|
        p.author = current_user
        p.set_next_available_slug(p.title.parameterize) if p.title.present?
        p.build_embeddable if p.embeddable.nil?
        if !p.content? && p.support_templates? &&
           p.embeddable_type.in?(Page.embeddable_types)
          p.template ||= p.template_class.default
        end
      end
      @page.move_to_child_with_index(@page.parent, 0) if @page.parent
    end
    flash_for @page
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def edit_metadata
    respond_to do |format|
      format.js
    end
  end

  def update
    @page.update(page_params) do |p|
      p.author = current_user
    end
    flash_for @page
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @page.destroy
    flash_for @page
    respond_with :admin, @page, location: [:admin, @page.right_sibling ||
      @page.left_sibling || @page.parent || Page.root]
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
        while Page.without(@page).exists?(parent_id: target_page.id, slug: slug)
          slug = slug.next
        end
        @page.update_column(:slug, slug)
        @page.move_to_child_with_index(target_page, 0)
      when 'before'
        while Page.without(@page).exists?(parent_id: target_page.parent_id,
                                          slug: slug)
          slug = slug.next
        end
        @page.update_column(:slug, slug)
        @page.move_to_left_of(target_page)
      when 'after'
        while Page.without(@page).exists?(parent_id: target_page.parent_id,
                                          slug: slug)
          slug = slug.next
        end
        @page.update_column(:slug, slug)
        @page.move_to_right_of(target_page)
      else
        return valid = false
      end

      # Update Path
      @page.refresh_path!(true)

      # Update Counter Caches
      [@page.id, @page.parent_id, target_page.id, target_page.parent_id,
       previous_parent_id].compact.uniq.each do |page_id|
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

  def change_template
    @page.check_template_support!
    template = Template.find(params[:template_id])
    @page.template = template
    @page.save!
    location = [:admin, @page, :regions]
    respond_to do |format|
      format.html { redirect_to location }
      format.js { redirect_via_turbolinks_to location }
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
            .includes(:translations).with_locales(Globalize.fallbacks)
            .references(:translations)
    @page_tree = Admin::PageTree.new(pages, selected: @page)
  end

  def load_page
    @page = Page.find(params[:id])
  end

  def load_parent_page
    parent_id = params[:page_id]
    page_params = params[:page]
    if parent_id
      @parent_page = Page.find_by(id: parent_id)
    elsif !request.get? && page_params
      @parent_page = Page.find_by(id: page_params[:parent_id])
    elsif @page
      @parent_page = @page.parent
    end
  end

  def new_page_params
    page_params = params.require(:page)
    embeddable_attributes_params = case page_params[:embeddable_type]
    when 'Page::ContactForm' then { recipient_ids: [] }
    when 'Page::Content' then [:template_id]
    when 'Page::Redirection'
      [:external, :destination_page_id, :destination_url, :permanent]
    end
    page_params.permit :embeddable_type, :parent_id, :title, :parent_id,
                       embeddable_attributes: embeddable_attributes_params || []
  end

  def page_params
    page_params = params.require(:page)
    embeddable_type = @page ? @page.embeddable_type : page_params[:embeddable_type]
    embeddable_attributes_params = case embeddable_type
    when 'Page::ContactForm' then [:id, :template_id, { recipient_ids: [] }]
    when 'Page::Content' then [:id, :template_id]
    when 'Page::Homepage' then [:id, :template_id]
    when 'Page::Image' then [:id, :image_id]
    when 'Page::Project' then [:id, :project_id]
    when 'Page::Redirection' then [:id, :external, :destination_page_id, :destination_url, :permanent]
    end
    page_params.permit :title, :template_id, :meta_keywords, :meta_description, :embeddable_id, :embeddable_type,
                       :slug, :parent_id, :published, :menu_item, :indexable,
                       embeddable_attributes: embeddable_attributes_params || []
  end

  def available_templates
    @page.available_templates.order(:name)
  end
end
