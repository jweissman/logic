module Logic
  module Evaluation
    class << self
      def analyze(expr, ctx={})
        result = if expr.is_a?(BinaryExpression)
          analyze_binary(expr, ctx)
        elsif expr.is_a?(BoundExpression)
          analyze(expr.expression, ctx.merge(expr.context))
        elsif expr.is_a?(ConstantExpression)
          expr
        elsif expr.is_a?(NegatedExpression)
          (!analyze(expr.expression, ctx))
        elsif expr.is_a?(VariableExpression)
          if ctx.has_key?(expr.name.to_sym)
            lift_bool ctx[expr.name.to_sym]
          else
            expr
          end
        elsif expr.is_a?(PredicateExpression) || expr.is_a?(QuantifiedExpression) || expr.is_a?(SimpleObjectExpression)
          # irreducible...
          expr
        else
          raise "Unknown type for analysis #{expr.class.name}"
        end
        result
      end

      def lift_bool(bool)
        if bool == true
          Truth
        else
          Falsity
        end
      end

      def analyze_binary(expr, ctx)
        left, right = analyze(expr.left, ctx), analyze(expr.right, ctx)
        case expr
        when BiconditionalExpression then
          analyze(left.implies(right).conjoin(right.implies(left)), ctx)
        when ConditionalExpression then
          analyze(left.negate.disjoin(right), ctx)
        when ConjoinedExpression then
          left.conjoin right
        when DisjoinedExpression
          left.disjoin right
        end
      end
    end
  end
end
