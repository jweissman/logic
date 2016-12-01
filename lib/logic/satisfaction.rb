module Logic
  module Satisfaction
    def can_fulfill?(expression)
      if expression.free_variables.any?
        # pick off free variables recursively?
        var_to_bind = expression.free_variables.first
        var_key = var_to_bind.to_sym

        # try true path first...
        bound_true = expression.bind(var_key => true)
        return true if can_fulfill?(bound_true)

        bound_false = expression.bind(var_key => false)
        return true if can_fulfill?(bound_false)

        false
      else
        # no free vars, just eval
        expression.evaluate
      end
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
        if can_fulfill?(expression)
          [expression.context]
        else
          []
        end
      end
    end
  end
end
