class PagesController < ApplicationController
  respond_to :html

  before_action :load_page
  before_action :load_template
  before_action :load_menu_items

  before_action :increment_hits

  attr_reader :page
  protected :page
  helper_method :page

  breadcrumbs do |b|
    pages = @page.self_and_ancestors.accessible_by(current_ability).with_translations_for_current_locale
    pages.each do |page|
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
  def render_page(options = {})
    render @page.template_path, options
  end

  def respond_with_page(options = {})
    @page.check_template_support!
    respond_with @page, options.merge(template: @page.template_path)
  end

  private
  def load_page
    pages = Page.accessible_by(current_ability).with_translations_for_current_locale
    if params[:path].blank?
      @page = pages.roots.first!
    else
      @page = pages.find_by!(path: params[:path])
    end
  end

  def load_template
    if @page.support_templates?
      @template = @page.template 
      @region_definitions = @template.region_definitions
    end
  end

  def load_menu_items
    @menu_items = Page.primary.published.menu_items.accessible_by(current_ability).with_translations_for_current_locale
  end

  def increment_hits
    @page.increment_hits!
  end
end