# == Schema Information
#
# Table name: images
#
#  id                    :integer          not null, primary key
#  asset_file_name       :string(255)
#  asset_content_type    :string(255)
#  asset_file_size       :integer
#  asset_updated_at      :datetime
#  width                 :integer
#  height                :integer
#  exif_data             :text
#  created_at            :datetime
#  updated_at            :datetime
#  author_id             :integer
#  customization_options :text
#  transformed_width     :integer
#  transformed_height    :integer
#

class Editor::Image < Activity
  attribute :external, Boolean, default: false
  attribute :image_id, Integer
  attribute :image_style, String
  attribute :url, String
  attribute :alternative_text, String
  attribute :persisted, Boolean, default: false
  attribute :width, Integer
  attribute :height, Integer

  validates :url, presence: true, if: :external?
  validates :image_id, presence: true, if: :internal?

  def internal?
    !external?
  end

  alias_method :internal, :internal?

  def internal=(internal)
    self.external = !internal
  end

  def image
    @image ||= ::Image.find(image_id)
  end

  def image=(image)
    self.image_id = image.id
    @image = image
  end

  def self.from_html(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html)
    new.tap do |instance|
      image = fragment.css('img')
      if image.present? and src = image.attribute('src').to_s and src.present?
        instance.persisted = true
        route = Rails.application.routes.recognize_path(src) rescue nil
        uri = URI.parse(src) rescue nil
        if uri.present? and uri.relative? and route.present? and route.key?(:id)
          if page = Page.find_by(path: route[:id])
            instance.page = page
            instance.locale = route[:locale] if I18n.available_locales.map(&:to_s).include?(route[:locale])
            instance.external = false
          end
        else
          instance.external = true
          instance.src = uri.to_s
        end
      else
        instance.persisted = false
      end
    end
  end

  def to_html(template)
    src = internal? ? image.asset.url(image_style) : url
    template.tag(:img, src: src, width: width, height: height, alt: alternative_text || '', data: { image_id: image_id, image_style: image_style }).html_safe
  end
end
