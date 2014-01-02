# == Schema Information
#
# Table name: contact_forms
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class ContactForm < ActiveRecord::Base
  include BatchTranslatable
  include HtmlContainable # TODO Does not work on description currently (only on body)
  include PageEmbeddable
  include Templatable

  self.template_type = 'Template::ContactForm'.freeze

  translates :title, :description, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_html_containable :description
  acts_as_page_embeddable destroy_with_page: true

  has_and_belongs_to_many :recipients, class_name: 'User', join_table: 'contact_form_recipients', foreign_key: 'contact_form_id', association_foreign_key: 'recipient_id'

  validates :recipient_ids, presence: true

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end