module I18nHelper
  def i18n_javascript
    javascript_tag do
      raw %{
        window.I18n || (window.I18n = {});
        window.I18n.locale = '#{I18n.locale}';
        window.I18n.translations = #{I18n.translate(:javascript, default: {}).to_json};
      }
    end
  end
end