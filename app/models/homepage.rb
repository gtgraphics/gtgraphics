# == Schema Information
#
# Table name: homepages
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Homepage < ActiveRecord::Base
  include PageEmbeddable
  include Templatable  

  self.template_type = 'Template::Homepage'.freeze

  acts_as_page_embeddable convertible: false, creatable: false, destroy_with_page: true

  has_many :quotes, class_name: 'Homepage::Quote', dependent: :destroy

  def title
    I18n.translate(:homepage)
  end
end
