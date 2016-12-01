module Logic
  class BoundExpression < Expression
    def initialize(expression, env={})
      @expression = expression
      @context = env
    end

    def name
      @expression.name + " [#{@context.map { |k,v| k.to_s + '=' + v.to_s }.join(',')}]"
    end

    def describe
      @expression.describe + " [#{@context.map { |k,v| k.to_s + '=' + v.to_s }.join(',')}]"
    end

    def context
      @context
    end

    # ignore bound vars here...
    def free_variables
      @expression.free_variables.reject do |var|
        @context.keys.include?(var.to_sym)
      end.sort
    end

    def evaluate(env={})
      @expression.evaluate(@context.merge(env))
    end
  end
end
