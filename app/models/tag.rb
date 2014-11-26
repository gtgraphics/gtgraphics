# == Schema Information
#
# Table name: tags
#
#  id    :integer          not null, primary key
#  label :string(255)      not null
#  slug  :string(255)      not null
#

class Tag < ActiveRecord::Base
  include Excludable
  include Sluggable

  has_slug from: :label, if: :label?, unless: :slug_changed?, on: :create

  has_many :taggings, dependent: :delete_all

  validates :label, presence: true, uniqueness: true, on: :create, strict: true
  validates :slug, presence: true, uniqueness: { if: :slug_changed? }

  attr_readonly :label

  class << self
    def [](label)
      find_or_initialize_by(label: label)
    end

    def applied_to(*records)
      applied_to_linked_with :or, *records
    end
    alias_method :applied_to_all, :applied_to
    alias_method :common, :applied_to

    def applied_to_any(*records)
      applied_to_linked_with :and, *records
    end

    def search(query)
      if query.present?
        where(arel_table[:label].matches("%#{query}%"))
      else
        all
      end
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
      group(arel_table[:id]).
      reorder('taggings_count').reverse_order
    end

    def popularity
      popularity_by { |tag| tag }
    end

    def popularity_by(column_name = nil)
      popular.inject({}) do |result, tag|
        if column_name
          key = tag[column_name]
        elsif block_given?
          key = yield(tag)
        else
          raise ArgumentError, 'no column name or block given'
        end
        result.merge!(key => tag.taggings_count)
      end
    end

    private
    def applied_to_linked_with(linking, *records)
      taggings = Tagging.arel_table
      conditions = records.flatten.map do |record|
        taggings[:taggable_id].eq(record.id).
        and(taggings[:taggable_type].eq(record.class.name))
      end.reduce(linking)
      Tag.joins(:taggings).where(conditions).uniq
    end
  end

  def appliers
    taggings.includes(:taggable).collect(&:taggable)
  end

  def to_s
    label
  end

  private
  def set_slug
    self.slug = generate_slug
    while self.class.where(slug: self.slug).without(self).exists?
      self.slug = self.slug.next
    end
  end
end
