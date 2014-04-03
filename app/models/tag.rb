# == Schema Information
#
# Table name: tags
#
#  id    :integer          not null, primary key
#  label :string(255)
#

class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :delete_all

  validates :label, presence: true, uniqueness: true

  default_scope -> { order(:label) }

  class << self
    def usage
      usage_by(:id)
    end

    def usage_by(column_name)
      taggings = Tagging.arel_table
      select_expression = arel_table.project(arel_table[column_name], taggings[:id].count.as('taggings_count')).projections
      join_expression = arel_table.join(taggings, Arel::Nodes::OuterJoin).on(taggings[:tag_id].eq(arel_table[:id])).join_sources
      joins(join_expression).select(select_expression).group(arel_table[:id]). \
        inject({}) { |result, tag| result.merge!(tag.attributes[column_name.to_s] => tag.taggings_count) }
    end
  end
end
