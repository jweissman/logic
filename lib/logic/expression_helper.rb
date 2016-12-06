module Logic
  module ExpressionHelper
    def subexpressions_for(expr)
      subexpressions = [expr]

      if expr.is_a?(BinaryExpression)
        subexpressions.push(subexpressions_for(expr.left))
        subexpressions.push(subexpressions_for(expr.right))
      elsif expr.is_a?(NegatedExpression) || expr.is_a?(BoundExpression)
        subexpressions.push(subexpressions_for(expr.expression))
      elsif expr.is_a?(QuantifiedExpression)
        subexpressions.push(subexpressions_for(expr.subject))
        subexpressions.push(subexpressions_for(expr.predicate))
      end

      subexpressions.flatten
    end
  end
end
