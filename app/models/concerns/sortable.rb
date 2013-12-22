module Sortable
  extend ActiveSupport::Concern

  class Columns
    def initialize(model)
      @model = model
      @columns = @model.sortable_columns_hash
    end

    def method_missing(name, options = {}, &block)
      if block_given?
        @columns[name] = Sortable::ColumnDefinition.new(name, block, options)
      else
        @columns[name] = Sortable::ColumnDefinition.new(name, @model.arel_table[name], options)
      end
    end
  end

  class ColumnDefinition
    attr_reader :name, :order

    def initialize(name, order, options = {})
      @name = name
      @order = order
      @default = options.fetch(:default, false)
    end

    def default?
      @default
    end
  end

  class Direction
    ASCENDING_STRING = 'ASC'
    DESCENDING_STRING = 'DESC'
    DESCENDING_TOKENS = %w(desc descending).freeze

    def initialize(direction)
      @descending = direction.to_s.downcase.in?(%w(desc descending))
    end

    def self.default
      new(:ascending)
    end

    def ascending?
      !@descending
    end
    alias_method :asc?, :ascending?

    def descending?
      @descending
    end
    alias_method :desc?, :descending?

    def inspect
      "#<#{self.class.name} descending: #{descending?}>"
    end

    def invert
      self.class.new(descending? ? :ascending : :descending)
    end

    def invert!
      @descending = !@descending
    end

    def to_s
      descending? ? DESCENDING_STRING : ASCENDING_STRING 
    end

    def to_sym
      descending? ? :desc : :asc
    end
  end

  module RelationExtension
    def sort_column
      @sort_column
    end

    def sort_column=(column)
      @sort_column = column.to_s
    end

    def sort_direction
      @sort_direction
    end

    def sort_direction=(direction)
      @sort_direction = Sortable::Direction.new(direction)
    end

    def sorted_by?(column, direction = nil)
      sort_column == column.to_s and (direction.nil? or direction == sort_direction)
    end
  end

  module ClassMethods
    def acts_as_sortable
      yield(Sortable::Columns.new(self))
    end

    def sortable_column_names
      sortable_columns_hash.keys
    end

    def sortable_columns
      sortable_columns_hash.values
    end

    def sortable_columns_hash
      @sortable_columns_hash ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def sort(column, direction = nil)
      relation = all.extending(Sortable::RelationExtension)

      sortable_column = sortable_columns_hash[column]
      sortable_column ||= sortable_columns.find(&:default?)

      relation.sort_column = sortable_column.name
      relation.sort_direction = direction || Sortable::Direction.default

      if sortable_column
        sortable_column_order = sortable_column.order
        if sortable_column_order.respond_to?(:call)
          order = case sortable_column_order.arity
          when 1 then sortable_column_order.call(relation.sort_direction)
          when 2 then sortable_column_order.call(relation.sort_column, relation.sort_direction)
          else raise 'invalid number of arguments' 
          end
          #raise order.inspect
        else
          order = sortable_column_order.send(relation.sort_direction.to_sym)
        end
        relation.reorder(order)
      else
        relation
      end
    end
  end
end