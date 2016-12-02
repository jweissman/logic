module Logic
  class SimpleObjectExpression < Expression
    def initialize(name)
      @name = name
    end

    def name
      @name
    end
  end
end
