module Logic
  class ConstantExpression < Expression
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def free_variables
      []
    end

    def reduce(*)
      self
    end
  end
end
