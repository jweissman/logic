module Logic
  class BoundExpression < Expression
    attr_accessor :expression, :context

    def initialize(expression, context)
      @expression = expression
      @context = context
    end

    def name
      @expression.name + " [#{@context.map { |k,v| k.to_s + '=' + v.to_s }.join(',')}]"
    end

    def describe
      @expression.describe + " [#{@context.map { |k,v| k.to_s + '=' + v.to_s }.join(',')}]"
    end

    def bind(ctx)
      BoundExpression.new(@expression, @context.merge(ctx))
    end

    # ignore bound vars here...
    def free_variables
      @expression.free_variables.reject do |var|
        @context.keys.include?(var.to_sym)
      end.sort
    end
  end
end
