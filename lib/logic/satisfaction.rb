module Logic
  module Satisfaction
    class << self
      def can_fulfill?(expression)
        solutions(expression).any?
      end

      def solutions(expression)
        sat_matches = []

        if expression.free_variables.any?
          var_to_bind = expression.free_variables.first
          var_key = var_to_bind.to_sym

          bound_true = expression.bind(var_key => true)
          solutions(bound_true).each do |true_sat|
            sat_matches.push({var_key => true}.merge(true_sat))
          end

          bound_false = expression.bind(var_key => false)
          solutions(bound_false).each do |false_sat|
            sat_matches.push({var_key => false}.merge(false_sat))
          end

          sat_matches
        else
          evaluated = expression.evaluate.reduce
          if evaluated == Truth
            [expression.context]
          else
            []
          end
        end
      end
    end
  end
end
