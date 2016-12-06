module Logic
  module Rewriting
    class << self
      include ExpressionHelper
      def elaborate(expr)
        @cached_elaborations ||= {}
        @cached_elaborations[expr] ||= elaborate!(expr).uniq
      end

      def elaborate!(expr)
        elaborations = []

        if expr.is_a?(BinaryExpression)
          elaborations += elaborate(expr.left).map do |left_elaboration|
            expr_copy = expr.dup
            expr_copy.left = left_elaboration
            expr_copy
          end

          elaborations += elaborate(expr.right).map do |right_elaboration|
            expr_copy = expr.dup
            expr_copy.right = right_elaboration
            expr_copy
          end
        elsif expr.is_a?(NegatedExpression) || expr.is_a?(BoundExpression)
          elaborations += elaborate(expr.expression).map do |inner_elaboration|
            expr_copy = expr.dup
            expr_copy.expression = inner_elaboration
            expr_copy
          end
        end

        elaborations += elaborating_theorems_for(expr).select { |rewrite| rewrite.left == (expr) }.map(&:right)

        # unique_rewritings = elaborations #.flat_map(&method(:elaborate))

        elaborations.reject { |rewrite| rewrite == expr } #.uniq { |rewrite| rewrite.name }
      end

      # # okay, we need to work through and find all the theorems that match us...

      # private
      def elaborating_theorems_for(expr)
        subexpressions = (subexpressions_for(expr)).uniq
        tautologies_for(subexpressions)
      end

      def tautologies_for(expressions)
        expressions.permutation.flat_map do |expression_permutation|
          x,y,z = *expression_permutation
          tautologies = []
          tautologies += Axioms.rewrite_single_variable(x) if x
          tautologies += Axioms.rewrite_two_variables(x,y) if x && y
          tautologies += Axioms.rewrite_three_variables(x,y,z) if x && y && z
          tautologies
        end
      end
    end
  end
end
