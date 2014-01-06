# == Schema Information
#
# Table name: snippets
#
#  id         :integer          not null, primary key
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Snippet < ActiveRecord::Base
  include Authorable
  include BatchTranslatable
  include HtmlContainable
  include Sortable

  has_many :regions, as: :concrete_region, dependent: :destroy

  translates :name, :body, fallbacks_for_empty_translations: true

  acts_as_authorable
  acts_as_batch_translatable
  acts_as_html_containable :body
  acts_as_sortable do |by|
    by.author { |dir| [User.arel_table[:first_name].send(dir.to_sym), User.arel_table[:last_name].send(dir.to_sym)] }
    by.name(default: true) { |column, dir| Snippet::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end
end
