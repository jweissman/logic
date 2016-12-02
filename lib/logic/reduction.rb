module Logic
  module Reduction
    class << self
      def simplify(expr, env={})
        if expr.is_a?(BinaryExpression)
          expr.left = simplify(expr.left)
          expr.right = simplify(expr.right)
        elsif expr.is_a?(NegatedExpression) || expr.is_a?(BoundExpression)
          expr.expression = simplify(expr.expression)
        end

        # p [ :simplify, expr: expr ]
        simplifying_theorem = simplifying_theorem_for(expr)
        if simplifying_theorem
          simplifying_theorem.right
        else
          expr
        end
      end

      private
      def simplifying_theorem_for(expr)
        return if expr.is_a?(VariableExpression) || expr.is_a?(ConstantExpression)

        subexpressions = (subexpressions_for(expr) - [expr]).uniq
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
        elsif expr.is_a?(PredicateQuery)
          subexpressions.push(subexpressions_for(expr.predicate))
          subexpressions.push(subexpressions_for(expr.expression))
        end

        subexpressions.flatten
      end

      def tautologies_for(expressions)
        Axioms.no_variable + expressions.permutation.flat_map do |expression_permutation|
          x,y,z = *expression_permutation
          tautologies = []
          tautologies += Axioms.single_variable(x) if x
          tautologies += Axioms.two_variable(x,y) if x && y
          tautologies += Axioms.three_variable(x,y,z) if x && y && z
          tautologies
        end
      end
    end
  end
end
