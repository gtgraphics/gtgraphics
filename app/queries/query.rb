class Query
  attr_reader :relation

  def initialize(relation)
    @relation = relation
  end

  def self.queries(name)
    instance_eval %{
      def #{name}
        @relation
      end
    }
  end

end