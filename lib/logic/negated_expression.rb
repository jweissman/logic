module Logic
  class NegatedExpression < Expression
    attr_accessor :expression

    def initialize(expression)
      @expression = expression
    end

    def name
      "~#{expression.name}"
    end

    def describe
      "not #{expression.describe}"
    end

    def free_variables
      expression.free_variables
    end
  end
end
