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
    def popular
      taggings_counts
    end

    def search(query)
      if query.present?
        where(arel_table[:label].matches("%#{query}%"))
      else
        all
      end
    end

    def usage
      usage_by(:id)
    end

    def usage_by(column_name)
      taggings_counts(column_name).inject({}) do |result, tag|
        result.merge!(tag.attributes[column_name.to_s] => tag.taggings_count)
      end
    end

    private
    def taggings_counts(*columns)
      columns = columns.map { |column| arel_table[column] }
      columns << arel_table[Arel.star] if columns.empty?
      taggings = Tagging.arel_table
      select_expression = arel_table.project(*columns, taggings[:id].count.as('taggings_count')).projections
      join_expression = arel_table.join(taggings, Arel::Nodes::OuterJoin).on(taggings[:tag_id].eq(arel_table[:id])).join_sources
      joins(join_expression).select(select_expression).group(arel_table[:id]).reorder('taggings_count DESC')
    end
  end

  def appliers
    taggings.includes(:taggable).collect(&:taggable)
  end

  def to_s
    label
  end
end
