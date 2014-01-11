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
  include PersistenceContextTrackable
  include Sortable

  has_many :regions, as: :concrete_region, dependent: :destroy

  translates :name, :body, fallbacks_for_empty_translations: true

  acts_as_authorable
  acts_as_batch_translatable
  acts_as_sortable do |by|
    by.name(default: true) { |column, dir| Snippet::Translation.arel_table[column].send(dir.to_sym) }
    by.updated_at
  end
end
