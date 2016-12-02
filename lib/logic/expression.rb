module Logic
  class Expression
    def name
      raise "TODO name this kind of expression (#{self.class.name})"
    end

    def describe
      name
    end

    def to_s
      name
    end

    def inspect
      describe
    end

    # structural (symbolic) equivalence
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

    def bind(ctx)
      BoundExpression.new(self, ctx)
    end

    def free_variables
      raise "TODO identify free vars in this kind of expression (#{self.class.name})"
    end

    def satisfiable?
      Satisfaction.can_fulfill?(self)
    end

    def solve
      Satisfaction.solutions(self)
    end

    def reduce
      Reduction.simplify(self)
    end

    def evaluate(*)
      raise "TODO Implement #evaluate for expression type #{self.class.name}"
    end

    def context
      {}
    end

    def is_a(predicate)
      PredicateQuery.new(predicate, self)
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
  end
end
