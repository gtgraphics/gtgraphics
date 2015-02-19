class Admin::Search
  SEARCHABLE_MODELS = %w(
    Page
    Image
    Project
  ).freeze

  RESULT_LIMIT = 5

  attr_reader :query

  def initialize(query)
    @query = query
  end

  def self.searchable_classes
    SEARCHABLE_MODELS.map(&:constantize)
  end

  def result
    self.class.searchable_classes.inject({}) do |result, model|
      result.merge!(model => model.search(query))
    end
  end

  def to_a
    result.values.flat_map(&:to_a)
  end

  def to_json(_options = {})
    arr = []
    result.each do |model, results|
      children = []
      count = results.count
      results.limit(RESULT_LIMIT).each do |r|
        children << { id: r.id, text: r.to_s,
                      type: r.class.name.demodulize.camelize(:lower) }
      end
      item = { text: "#{model.model_name.human} (#{count})",
               children: children }
      arr << item if children.any?
    end
    arr.to_json
  end
end
