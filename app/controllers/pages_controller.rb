class PagesController < ApplicationController
  respond_to :html

  before_action :set_page_locale
  before_action :load_page
  before_action :load_template

  authorize_resource class: 'Page', parent: false, only: :edit

  attr_reader :page
  protected :page
  helper_method :page
  helper_method :editable?, :editing?

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

  protected
  def editable?
    can?(:update, @page || Page)
  end

  def editing?
    editable? and params[:editing].to_b
  end

  def default_url_options(options = {})
    if editing?
      super.merge(page_locale: @page_locale)
    else
      super
    end
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
      @page = Page.accessible_by(current_ability).find_by!(path: params[:path])
    end
  end

  def load_template
    if @page.supports_template?
      @template = @page.template 
      @region_definitions = @template.try(:region_definitions) if @page.supports_regions?
    end
  end

  def set_page_locale
    if editing?
      available_locales = I18n.available_locales.map(&:to_s)
      if page_locale = params[:page_locale] and page_locale.in?(available_locales)
        @editor_locale = params[:locale]
        I18n.locale = @page_locale = page_locale
      else
        @page_locale = @editor_locale = I18n.locale
      end
    else
      @page_locale = I18n.locale
    end
  end
end