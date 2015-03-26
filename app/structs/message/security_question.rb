class Message < ActiveRecord::Base
  class SecurityQuestion
    OPERATORS = %i(+ * -)
    NUMBERS = (1..10)

    def self.generate
      operator = OPERATORS.sample
      left = rand(NUMBERS)
      right = rand(NUMBERS)
      new(operator, left, right)
    end

    attr_reader :left, :right, :operator

    def initialize(operator, left, right)
      @operator = operator
      @left = left
      @right = right
    end

    def result
      [left, right].reduce(operator)
    end

    def valid?(answer)
      answer = answer.strip if answer.respond_to?(:strip)
      answer = answer.to_i
      result == answer
    end

    def text
      I18n.translate(operator, scope: 'views.messages.security_questions')
        .sample % { left: left, right: right, operator: operator.to_s }
    end

    def to_s
      text
    end

    def self.load(dump)
      if dump.present? && dump.respond_to?(:to_a) && dump.length == 3
        operator, left, right = dump
        new(operator.to_sym, left.to_i, right.to_i)
      else
        generate
      end
    end

    def dump
      [operator, left, right].map(&:to_s)
    end
  end
end
