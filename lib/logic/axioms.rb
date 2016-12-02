module Logic
  module Axioms
    class << self
      def no_variable
        [
          ~Truth > Falsity,
          ~Falsity > Truth
        ]
      end

      # lists of 'theorematic' expressions describing some reduction rules
      def single_variable(x)
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

          # self-implication resolves to T
          (x > x) > Truth,

        ]
      end

      def two_variable(x,y)
        [
          # modus ponens
          (x > y) ^ x > y,

          # conjunction absorbs disjunctions
          x ^ (x | y) > x,

          # disjunction absorbs conjunctions
          x | (x ^ y) > x,
        ]
      end

      def three_variable(x,y,z)
        [
          # curry
          x > y > z > ((x ^ y) > z),

          # universal quantification modus ponens
          ( Logic.all(y).are(z) ).conjoin( x.is_a(y) ).implies( x.is_a(z) ).implies(Truth),
        ]
      end
    end
  end
end
