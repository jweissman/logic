require 'logic/version'

module Logic
  class Term
    extend Forwardable
    def_delegators :to_expression, :negate, :conjoin, :disjoin, :implies
  end

  class Constant < Term
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def to_expression
      ConstantExpression.new(self.name, self.value)
    end
  end

  Truth = Constant.new("T", true)
  Falsity = Constant.new("F", false)

  class Variable < Term
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def to_expression
      SimpleExpression.new(self)
    end
  end

  class Expression
    def name
      raise "TODO name this kind of expression (#{self.class.name})"
    end

    def describe
      name
    end

    def reduce(env={})
      raise "TODO implement #reduce for this kind of expression (#{self.class.name})"
    end

    # def to_s
    #   name
    # end
    #
    # def inspect
    #   describe
    # end

    # expressions are considered 'equal' if satisfiers are equivalent
    # note this has weird effect that all tautologically-false statements are equivalent
    def ==(other)
      satisfiers == other.satisfiers
    end

    def negate
      NegatedExpression.new(self)
    end

    def conjoin(other)
      ConjoinedExpression.new(self, expressionize(other))
    end

    def disjoin(other)
      DisjoinedExpression.new(self, expressionize(other))
    end

    def implies(other)
      ConditionalExpression.new(self, expressionize(other))
    end

    def bind(env)
      BoundExpression.new(self, env)
    end

    def free_variables
      raise "TODO identify free vars in this kind of expression (#{self.class.name})"
    end

    def satisfiable?
      if free_variables.any?
        # pick off free variables recursively?
        var_to_bind = free_variables.first
        var_key = var_to_bind.name.to_sym

        # try true path first...
        bound_true = bind(var_key => true)
        return true if bound_true.satisfiable?

        bound_false = bind(var_key => false)
        return true if bound_false.satisfiable?

        false
      else
        # no free vars, just eval
        evaluate
      end
    end

    def context
      {}
    end

    def satisfiers
      sat_matches = []

      if free_variables.any?
        var_to_bind = free_variables.first
        var_key = var_to_bind.name.to_sym

        bound_true = bind(var_key => true)
        bound_true.satisfiers.each do |true_sat|
          sat_matches.push({var_key => true}.merge(true_sat))
        end

        bound_false = bind(var_key => false)
        bound_false.satisfiers.each do |false_sat|
          sat_matches.push({var_key => false}.merge(false_sat))
        end

        sat_matches
      else
        if satisfiable?
          [context]
        else
          []
        end
      end
    end

    protected
    def parenthesize(str)
      if (logic_symbols - ['~']).any? { |sym| str.include?(sym) } || (logic_words - ['not']).any? { |sym| str.include?(sym) }
        "(#{str})"
      else
        str
      end
    end

    private
    def logic_symbols
      %w[ ^ v ~ -> ]
    end

    def logic_words
      %w[ and or not then ]
    end

    def expressionize(thing)
      return thing if thing.is_a?(Expression)
      if thing.is_a?(Variable)
        thing.to_expression
      else
        raise "Unknown term kind #{thing.class.name} (unable to coerce into expression)"
      end
    end
  end

  class ConstantExpression < Expression
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def free_variables
      []
    end

    def evaluate(*)
      value
    end
  end

  class SimpleExpression < Expression
    def initialize(term)
      @term = term
    end

    def name
      term.name
    end

    def describe
      name
    end

    def free_variables
      [term]
    end

    def evaluate(env={})
      raise "Env (#{env}) does not contain term #{term.name}" unless env.include?(name.to_sym)
      env[name.to_sym]
    end

    def reduce(env={})
      if env.has_key?(name.to_sym)
        lift_bool evaluate(env)
      else
        self
      end
    end

    def lift_bool(true_or_false)
      if true_or_false
        Truth.to_expression
      else
        Falsity.to_expression
      end
    end

    private
    attr_reader :term
  end

  class NegatedExpression < Expression
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

    def evaluate(env={})
      !expression.evaluate(env)
    end

    private
    attr_reader :expression
  end

  class BoundExpression < Expression
    def initialize(expression, env={})
      @expression = expression
      @context = env
    end

    def context
      @context
    end

    def reduce
      @expression.reduce(@context)
    end

    # ignore bound vars here...
    def free_variables
      @expression.free_variables.reject do |var|
        @context.keys.include?(var.name.to_sym)
      end.sort_by(&:name)
    end

    def evaluate(env={})
      @expression.evaluate(@context.merge(env))
    end
  end

  class BinaryExpression < Expression
    attr_reader :left, :right

    def initialize(left, right)
      raise unless left.is_a?(Expression) && right.is_a?(Expression)
      @left = left
      @right = right
    end

    def name
      "#{parenthesize @left.name}#{operator_glyph}#{parenthesize @right.name}"
    end

    def describe
      "#{parenthesize @left.describe} #{operator_description} #{parenthesize @right.describe}"
    end

    def free_variables
      (@left.free_variables + @right.free_variables).uniq.sort_by(&:name)
    end

    def operator_glyph
      raise "override #operator_name in #{self.class.name}"
    end

    def operator_description
      raise "override #operator_description in #{self.class.name}"
    end
  end

  class ConjoinedExpression < BinaryExpression
    def evaluate(env={})
      @left.evaluate(env) && @right.evaluate(env)
    end

    def operator_glyph
      '^'
    end

    def operator_description
      'and'
    end

    def reduce(env={})
      if (@right.reduce(env)) == Truth.to_expression
        @left.reduce(env)
      elsif (@right.reduce(env)) == Falsity.to_expression
        Falsity.to_expression
      elsif (@right.is_a?(DisjoinedExpression) && @right.left == @left)
        @left
      else
        self
        # Falsity.to_expression
      end
    end
  end

  class DisjoinedExpression < BinaryExpression
    def evaluate(env={})
      @left.evaluate(env) || @right.evaluate(env)
    end

    def operator_glyph
      'v'
    end

    def operator_description
      'or'
    end

    def reduce(env={})
      if @right.reduce(env) == Falsity.to_expression
        @left.reduce(env)
      elsif @right.reduce(env) == Truth.to_expression
        Truth.to_expression
      elsif (@right.is_a?(ConjoinedExpression) && @right.left == @left)
        @left
      else
        self
      end
    end
  end

  class ConditionalExpression < BinaryExpression
    def evaluate(env={})
      @left.negate.disjoin(@right).evaluate(env)
    end

    def operator_glyph
      '->'
    end

    def operator_description
      'then'
    end
  end
end
