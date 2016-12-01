module Logic
  class Expression
    include Satisfaction
    include Reduction

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
      name == other.name
    end

    # truth-functional equivalence
    # (expressions are considered 'equal' if satisfiers [truth table] are equivalent)
    def match(other)
      solve == other.solve
    end
    alias :=~ :match

    def negate
      NegatedExpression.new(self)
    end
    alias :-@ :negate
    alias :~ :negate
    alias :! :negate

    def conjoin(other)
      ConjoinedExpression.new(self, (other))
    end
    alias :^ :conjoin

    def disjoin(other)
      DisjoinedExpression.new(self, (other))
    end
    alias :| :disjoin

    def implies(other)
      ConditionalExpression.new(self, (other))
    end
    alias :> :implies

    def iff(other)
      BiconditionalExpression.new(self, (other))
    end
    alias :% :iff

    def bind(env)
      BoundExpression.new(self, env)
    end

    def free_variables
      raise "TODO identify free vars in this kind of expression (#{self.class.name})"
    end

    def satisfiable?
      can_fulfill?(self)
    end

    def context
      {}
    end

    def solve
      solutions(self)
    end

    def reduce(env={})
      simplify(self, env)
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
      %w[ ^ v ~ -> <-> ]
    end

    def logic_words
      %w[ and or not then iff ]
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

    def evaluate(env={})
      raise "Env (#{env}) does not contain term #{term.name}" unless env.include?(name.to_sym)
      env[name.to_sym]
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
      (@left.free_variables + @right.free_variables).uniq.sort
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

  class BiconditionalExpression < BinaryExpression
    def evaluate(env={})
      @left.implies(@right).conjoin(@right.implies(@left))
    end

    def operator_glypt
      '<->'
    end

    def operator_description
      'iff'
    end
  end

  Truth = ConstantExpression.new("T", true).freeze
  Falsity = ConstantExpression.new("F", false).freeze
end
