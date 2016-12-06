module Logic
  module Reduction
    class << self
      include ExpressionHelper

      def simplify(expr, env={})
        @simplified ||= {}
        @simplified[env] ||= {}
        @simplified[env][expr] ||= simplify!(expr, env)
      end

      def simplify!(expr, env={})
        if expr.is_a?(BinaryExpression)
          expr.left = simplify(expr.left)
          expr.right = simplify(expr.right)
        elsif expr.is_a?(NegatedExpression) || expr.is_a?(BoundExpression)
          expr.expression = simplify(expr.expression)
        end

        simplifying_theorem = simplifying_theorem_for(expr)
        if simplifying_theorem
          if simplifying_theorem.name == expr.name
            Truth
          else
            simplifying_theorem.right
          end
        else
          expr
        end
      end

      private
      def simplifying_theorem_for(expr)
        return if expr.is_a?(VariableExpression) || expr.is_a?(ConstantExpression)

        subexpressions = (subexpressions_for(expr) - [expr]).uniq
        theorems = tautologies_for(subexpressions)

        # p [:simplify, expr: expr, theorems: theorems.count]
        theorems.detect do |rule|
          expr.name == rule.left.name || expr.name == rule.name
        end
      end

      def tautologies_for(expressions)
        Axioms.no_variable + expressions.permutation.flat_map do |expression_permutation|
          x,y,z = *expression_permutation
          tautologies = []
          tautologies += Axioms.three_variable(x,y,z) if x && y && z
          tautologies += Axioms.two_variable(x,y) if x && y
          tautologies += Axioms.single_variable(x) if x
          tautologies
        end
      end
    end
  end
end
