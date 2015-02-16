# == Schema Information
#
# Table name: tags
#
#  id    :integer          not null, primary key
#  label :string(255)
#

class Tag < ActiveRecord::Base
  include Excludable

  sanitizes :label, with: :squish

  has_many :taggings, dependent: :delete_all

  validates :label, presence: true, uniqueness: { allow_blank: true }

  attr_readonly :label

  class << self
    def applied_to(*records)
      options = records.extract_options!
      if options.fetch(:any, false)
        applied_to_any(records)
      else
        applied_to_all(records)
      end
    end

    alias_method :common, :applied_to

    def search(query)
      return all if query.blank?
      where(arel_table[:label].matches("%#{query}%"))
    end

    def popular
      taggings = Tagging.arel_table

      taggings_count = taggings[:id].count.as('taggings_count')
      taggings_count.distinct = true
      select_expression = arel_table.project(
        arel_table[Arel.star], taggings_count
      ).projections

      join_expression = arel_table.join(taggings, Arel::Nodes::OuterJoin).
        on(taggings[:tag_id].eq(arel_table[:id])).join_sources

      joins(join_expression).select(select_expression).
      group(arel_table[:id]).order('taggings_count DESC')
    end

    def popularity
      popularity_by { |tag| tag }
    end

    def popularity_by(column_name = nil)
      popular.each_with_object({}) do |tag, result|
        if column_name
          key = tag[column_name]
        elsif block_given?
          key = yield(tag)
        else
          fail ArgumentError, 'no column name or block given'
        end
        result.merge!(key => tag.taggings_count)
      end
    end

    private

    def applied_to_any(records)
      taggings = Tagging.arel_table
      conditions = records.flatten.map do |record|
        taggings[:taggable_id].eq(record.id).
        and(taggings[:taggable_type].eq(record.class.name))
      end.reduce(:or)
      joins(:taggings).where(conditions).uniq
    end

    def applied_to_all(records)
      taggings = Tagging.arel_table
      conditions = records.flatten.map do |record|
        Tag.arel_table[:id].in(
          Tagging.where(
            taggings[:taggable_type].eq(record.class.name).and(
              taggings[:taggable_id].eq(record.id)
            )
          ).select(taggings[:tag_id]).ast
        )
      end.reduce(:and)
      where(conditions)
    end
  end

  def appliers
    taggings.includes(:taggable).collect(&:taggable)
  end

  def to_param
    label
  end

  def to_s
    label
  end
end
