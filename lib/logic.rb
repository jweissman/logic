require 'logic/version'

module Logic
  class Term
    extend Forwardable
    def_delegators :to_expression, :describe, :negate, :conjoin, :disjoin, :implies, :reduce, :|, :^, :-@, :>, :~, :!, :=~
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

    def to_s
      name
    end

    def inspect
      describe
    end

    # structural-equivalence
    def ==(other)
      reduce.name == other.reduce.name
    end

    # truth-functional equivalence
    # (expressions are considered 'equal' if satisfiers [truth table] are equivalent)
    def match(other)
      satisfiers == other.satisfiers
    end
    alias :=~ :match

    def negate
      NegatedExpression.new(self)
    end
    alias :-@ :negate
    alias :~ :negate
    alias :! :negate

    def conjoin(other)
      ConjoinedExpression.new(self, expressionize(other))
    end
    alias :^ :conjoin

    def disjoin(other)
      DisjoinedExpression.new(self, expressionize(other))
    end
    alias :| :disjoin

    def implies(other)
      ConditionalExpression.new(self, expressionize(other))
    end
    alias :> :implies

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

    def reduce(*)
      self
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

    def lift_bool(b)
      b ? Truth : Falsity
    end

    private
    attr_reader :term
  end

  class NegatedExpression < Expression
    attr_reader :expression

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

    def reduce(env={})
      expr = @expression.reduce(env)
      if expr == Truth
        Falsity
      elsif expr == Falsity
        Truth
      elsif @expression.is_a?(NegatedExpression)
        @expression.expression # involute
      else
        expr.negate
      end
    end
  end

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
      # "#{parenthesize @left.describe} #{operator_description} #{parenthesize @right.describe}"
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
      reduced = reduce(env)
      if reduced.is_a?(ConjoinedExpression)
        @left.evaluate(env) && @right.evaluate(env)
      else
        reduced.evaluate(env)
      end
    end

    def operator_glyph
      '^'
    end

    def operator_description
      'and'
    end

    def reduce(env={})
      l,r = @left.reduce(env), @right.reduce(env)
      if r == Truth
        l
      elsif r == Falsity
        Falsity
      elsif (r.is_a?(DisjoinedExpression) && r.left.reduce(env) == l)
        l
      elsif l == r.negate
        Falsity
      else
        self
      end
    end
  end

  class DisjoinedExpression < BinaryExpression
    def evaluate(env={})
      reduced = reduce(env)
      if reduced.is_a?(DisjoinedExpression)
        @left.evaluate(env) || @right.evaluate(env)
      else
        reduced.evaluate(env)
      end
    end

    def operator_glyph
      'v'
    end

    def operator_description
      'or'
    end

    def reduce(env={})
      if @right.reduce(env) == Falsity
        @left.reduce(env)
      elsif @right.reduce(env) == Truth
        Truth
      elsif (@right.is_a?(ConjoinedExpression) && @right.left == @left)
        @left
      elsif @left == @right.negate
        Truth
      elsif @left == @right
        @left
      else
        self
      end
    end
  end

  class ConditionalExpression < BinaryExpression
    def evaluate(env={})
      @left.reduce(env).negate.disjoin(@right.reduce(env)).evaluate(env)
    end

    def reduce(env={})
      l,r = @left.reduce(env), @right.reduce(env)
      if l == Truth
        r
      elsif r.is_a?(ConditionalExpression) # currying!
        ConditionalExpression.new(l.conjoin(r.left), r.right)
      else
        self
      end
    end

    def operator_glyph
      '->'
    end

    def operator_description
      'then'
    end
  end

  Truth = Constant.new("T", true).to_expression.freeze
  Falsity = Constant.new("F", false).to_expression.freeze
end
