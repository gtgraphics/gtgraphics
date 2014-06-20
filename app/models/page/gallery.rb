# == Schema Information
#
# Table name: gallery_pages
#
#  id          :integer          not null, primary key
#  template_id :integer          not null
#

class Page < ActiveRecord::Base
  class Gallery < ActiveRecord::Base
    include Page::Embeddable
    
    acts_as_page_embeddable template_class: 'Template::Gallery'

    def image_tokens
      @image_tokens ||= TokenCollection.new(page.try(:children).try(:images).try(:collect) { |page| page.embeddable.image_id }, unique: true)
    end

    def image_tokens=(tokens)
      @image_tokens = TokenCollection.new(tokens, unique: true)
    end
  end
end
