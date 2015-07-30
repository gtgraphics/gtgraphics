module Admin
  module TagHelper
    def add_tag_path(*tags)
      added_tags = tags.flatten.collect(&:label)
      tags = (selected_tags + added_tags).presence
      url_for(safe_params.except(:page).merge(tag: tags))
    end

    def remove_tag_path(*tags)
      removed_tags = tags.flatten.collect(&:label)
      tags = (selected_tags - removed_tags).presence
      url_for(safe_params.except(:page).merge(tag: tags))
    end

    def selected_tags
      Array(safe_params[:tag])
    end
  end
end
