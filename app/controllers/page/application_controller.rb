class Page::ApplicationController < ApplicationController
  respond_to :html

  before_action :load_page
  before_action :load_template

  before_action :increment_hits

  attr_reader :page
  protected :page
  helper_method :page, :template_file

  breadcrumbs do |b|
    pages = @page.self_and_ancestors.accessible_by(current_ability)
            .with_translations_for_current_locale
    pages.each do |page|
      b.append page.title, page
    end
  end

  def show
    if respond_to?(@template.filename)
      send(@template.filename)
    else
      respond_with_page
    end
  end

  protected

  def render_page(options = {})
    render template_path, options
  end

  def respond_with_page
    respond_to do |format|
      format.html { render_page }
      yield(format) if block_given?
    end
  end

  def template_file
    @page.check_template_support!
    @template.filename.inquiry
  end

  def template_path
    "#{@page.embeddable_type.underscore.pluralize}/templates/#{template_file}"
  end

  private
  def load_page
    @page = Page.accessible_by(current_ability)
            .find_by!(path: params[:path] || '')
  end

  def load_template
    return unless @page.support_templates?
    @template = @page.template
    @region_definitions = @template.region_definitions
  end

  def load_menu_items
    @menu_items = Page.primary.published.menu_items
                  .accessible_by(current_ability)
                  .with_translations_for_current_locale
  end

  def increment_hits
    @page.increment_hits!
  end
end
