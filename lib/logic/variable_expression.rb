module Logic
  class VariableExpression < Expression
    def initialize(name)
      @name = name
    end

    def name
      @name
    end

    def describe
      @name
    end

    def free_variables
      [@name]
    end
  end
end
