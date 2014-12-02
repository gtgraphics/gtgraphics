module Admin::TaggablePresenter
  extend ActiveSupport::Concern

  def tag_list(options = {})
    size = options[:size]
    h.content_tag :ul, class: ['tags', size ? "tags-#{size}" : nil].compact do
      object.tags.each do |tag|
        list_item = h.content_tag :li, tag.label, class: ['tag', size ? "tag-#{size}" : nil].compact
        h.concat list_item
      end
    end
  end
end