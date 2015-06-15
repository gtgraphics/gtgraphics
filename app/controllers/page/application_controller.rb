class Page::ApplicationController < ApplicationController
  include Router::ControllerAdapter

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
    respond_with_page
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
    File.join(@page.embeddable_type.underscore.pluralize,
              'templates', template_file)
  end

  private

  def load_page
    @page = env['cms.page.instance']
    # fail ActiveRecord::RecordNotFound if cannot? :read, @page
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

  def set_locale
    available_locales = I18n.available_locales.map(&:to_s)
    locale = params[:locale]
    if locale && locale.in?(available_locales)
      Globalize.locale = I18n.locale = locale.to_sym
    else
      # if user is logged in his preferred locale will be used
      # if none of the above is set the locale will be determined through the
      # HTTP Accept Language header from the browser
      locale = http_accept_language
               .compatible_language_from(I18n.available_locales)
      locale = I18n.default_locale if locale.blank?
      redirect_to "/#{File.join(*[locale.to_s, params[:path].presence].compact)}" # TODO: Use url helper

      # redirect_to params.to_h.with_indifferent_access.merge(
      #   locale: locale.to_s)
    end
  end
end
