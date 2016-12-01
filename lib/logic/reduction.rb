module Logic
  module Reduction
    # okay, this works but we could ask for tautologies in terms of expressions
    # rather than free variables... and do the search recursively?
    def simplify(expr, env={})
      # try to match tautologies instead of all this boilerplate!!
      theorems = tautologies_for(expr.free_variables)

      theorems.inject(expr) do |res, rule|
        # p [ :simplify, apply: rule ]
        l, r = rule.left, rule.right
        if res.name == l.name
          # p [ :rewrite, was: res, now: r ]
          r
        else
          res
        end
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

    def tautologies_for(var_names)
      var_expressions = var_names.map do |name|
        VariableExpression.new(name)
      end

      var_expressions.permutation.flat_map do |variable_expressions|
        x,y,z = *variable_expressions
        tautologies = []
        tautologies += single_variable_axioms(x) if x
        tautologies += two_variable_axioms(x,y) if x && y
        tautologies += three_variable_axioms(x,y,z) if x && y && z
        tautologies
      end
    end
  end
end
