module Logic
  class PredicateQuery < Expression
    attr_reader :predicate, :expression

    def initialize(predicate, expression)
      @predicate = predicate
      @expression = expression
    end

    def name
      "#{@predicate.name}[#{@expression.name}]"
    end

    def describe
      "#{@expression.name} is a #{@predicate.name}"
    end
  end

  # predicates have arbitrary arity...
  class PredicateExpression < Expression
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def evaluate(env={})
      # ???
      self
    end

    # def find(expr)
    #   PredicateQuery.new(self, expr)
    # end
    # alias :[] :find
  end

  class QuantifiedExpression < Expression
  end

  class ExistentiallyQuantifiedExpression < QuantifiedExpression; end
  class UniversallyQuantifiedExpression < QuantifiedExpression; end
end
