module LocalizableController
  extend ActiveSupport::Concern

  included do
    before_action :detect_locale
    before_action :set_locale
  end

  protected
  def accepted_languages
    @accepted_languages ||= begin
      # no language accepted
      return [] if request.env["HTTP_ACCEPT_LANGUAGE"].nil?
      
      # parse Accept-Language
      accepted = request.env["HTTP_ACCEPT_LANGUAGE"].split(",")
      accepted.map! { |l| l.strip.split(";") }
      accepted.map! do |l|
        if l.size == 2
          # quality present
          [ l.first.split("-").first.downcase.to_sym, l[1].sub(/^q=/, "").to_f ]
        else
          # no quality specified =&gt; quality == 1
          [ l.first.split("-").first.downcase.to_sym, 1.0 ]
        end
      end
      
      # sort by quality
      accepted.sort! { |l1, l2| l2.last <=> l1.last }
    end
  end

  def accepted_locales
    accepted_languages.map(&:first).uniq
  end

  private
  def detect_locale
    if params[:locale]
      session[:locale] = params[:locale]
      redirect_to locale: nil
    else
      session[:locale] ||= accepted_locales.first if accepted_locales.any?
    end
  end

  def set_locale
    I18n.locale = try(:current_user).try(:locale) || params[:locale] || session[:locale] || I18n.default_locale
  end
end