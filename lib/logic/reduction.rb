module Logic
  module Reduction
    def simplify(expr, env={})
      simplifying_theorem = simplifying_theorem_for(expr)
      if simplifying_theorem
        simplifying_theorem.right
      else
        expr
      end
    end

    def simplifying_theorem_for(expr)
      subexpressions = subexpressions_for(expr) - [expr]
      theorems = tautologies_for(subexpressions)
      theorems.detect do |rule|
        expr.name == rule.left.name
      end
    end

    def subexpressions_for(expr)
      subexpressions = [expr]

      if expr.is_a?(BinaryExpression)
        subexpressions.push(subexpressions_for(expr.left))
        subexpressions.push(subexpressions_for(expr.right))
      elsif expr.is_a?(NegatedExpression) || expr.is_a?(BoundExpression)
        subexpressions.push(subexpressions_for(expr.expression))
      end

      subexpressions.flatten.uniq
    end

    def tautologies_for(expressions)
      expressions.permutation.lazy.flat_map do |expression_permutation|
        x,y,z = *expression_permutation
        tautologies = []
        tautologies += single_variable_axioms(x) if x
        tautologies += two_variable_axioms(x,y) if x && y
        tautologies += three_variable_axioms(x,y,z) if x && y && z
        tautologies
      end
    end

    # lists of 'theorematic' expressions describing some reduction rules
    def single_variable_axioms(x)
      [
        ## conjunction
        # identity
        x ^ Truth > x,

        # annihilator
        x ^ Falsity > Falsity,

        # idempotence
        x ^ x > x,

        ## disjunction
        # identity
        x | Falsity > x,

        # annihilator
        x | Truth > Truth,

        # idempotence
        x | x > x,

        ## complementation
        # involution
        --x > x,

        # 'resolution'
        x ^ -x > Falsity,
        x | -x > Truth,
      ]
    end

    def two_variable_axioms(x,y)
      [
        # modus ponens
        (x > y) ^ x > y,

        # conjunction absorbs dijunctions
        x ^ (x | y) > x,

        # disjunction absorbs conjunctions
        x | (x ^ y) > x,
      ]
    end

    def three_variable_axioms(x,y,z)
      [
        # curry
        x > y > z > ((x ^ y) > z),
      ]
    end
  end
end
