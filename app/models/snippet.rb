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
  include Ownable
  include PersistenceContextTrackable

  translates :name, :body, fallbacks_for_empty_translations: true

  has_owner :author
  
  def to_liquid
    { 'snippet' => name }
  end
end
