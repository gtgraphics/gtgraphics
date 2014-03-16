class PagesController < ApplicationController
  respond_to :html

  before_action :load_page
  before_action :load_template

  authorize_resource class: 'Page', parent: false, only: :edit

  attr_reader :page
  protected :page
  helper_method :page
  helper_method :editing?

  breadcrumbs do |b|
    @page.self_and_ancestors.accessible_by(current_ability).with_translations.each do |page|
      b.append page.title, page
    end
  end

  class << self
    def embeds(embeddable_name)
      method_name = embeddable_name.to_sym

      helper_method method_name
      attr_reader method_name
      protected method_name

      before_action do
        instance_variable_set("@#{embeddable_name}", @page.embeddable)
      end
    end
  end

  def show
    respond_with_page
  end

  def edit
    #I18n.locale = current_user.preferred_locale if current_user.preferred_locale
    #respond_with @page, layout: 'page_editor'
    show
  end

  protected
  def editing?
    action_name.in? %w(edit update)
  end

  def render_page(options = {})
    render @page.template_path, options
  end

  def respond_with_page(options = {})
    unless @page.embeddable_class.supports_template?
      raise ActionView::MissingTemplate, "#{@page.embeddable_class} does not support templates"
    end
    respond_with @page, options.merge(template: @page.template_path)
  end

  private
  def load_page
    if params[:path].blank?
      @page = Page.accessible_by(current_ability).roots.first!
    else
      @page = Page.accessible_by(current_ability).find_by_path!(params[:path])
    end
  end

  def load_template
    if @page.supports_template?
      @template = @page.template 
      @region_definitions = @template.try(:region_definitions) if @page.supports_regions?
    end
  end
end