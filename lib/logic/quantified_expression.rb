module Logic
  class QuantifiedExpression < Expression
    def initialize(predicate, expression)
      @predicate = predicate
      @expression = expression
    end
  end

  class UniversallyQuantifiedExpression < QuantifiedExpression
    def name
      "{#{@predicate}=>#{@expression}}"
    end

    def describe
      "all #{@predicate} are #{@expression}"
    end
  end

  class ExistentiallyQualifiedExpression < QuantifiedExpression
    def name
      "{#@predicate=>#@expression}"
    end

    def describe
      "some #@predicate are #@expression"
    end
  end

  class QuantifierBuilder
    def initialize(klass, predicate)
      @klass = klass
      @predicate = predicate
    end

    def are(expression)
      @klass.new(@predicate, expression)
    end
  end
end
