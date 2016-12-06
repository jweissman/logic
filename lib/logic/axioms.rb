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

          # self-implication
          x > x > Truth,

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

          # all implies some??
          # all(x).are(y) > some(x).are(y),
        ]
      end

      def three_variable(x,y,z)
        [
          # curry
          x > y > z > ((x ^ y) > z),

          # universal quantification modus ponens
          (all(y).are(z) ^ x.is_a(y)) > x.is_a(z),

          # # valid syllogism forms (24)
          # # barbara (aaa)
          (all(x).are(y) ^ all(y).are(z)) > all(x).are(z),

          # # barbari (aai) ??
          # (all(x).are(y) ^ all(y).are(z)) > some(x).are(z),

          # # baroco (aoo)
          (all(x).are(y) ^ not_all(y).are(z)) > not_all(x).are(z),

          # # bocardo (oao)
          (not_all(x).are(y) ^ all(y).are(z)) > not_all(x).are(z),

          # # celarent (eae)
          (all(x).are(y) ^ no(y).are(z)) > no(x).are(z),

          # # ferioque (eio)
          (no(x).are(y) ^ some(y).are(z)) > not_all(x).are(z),

          # ( Logic.all(y).are(z) ).conjoin( x.is_a(y) ).implies( x.is_a(z) ).implies(Truth),
        ]
      end

      # rewriting
      def rewrite_single_variable(x)
        [
          # introduce ^ with self??
          x > (x ^ x),

          x > (x | x),
        ]
      end

      def rewrite_two_variables(x,y)
        [
          # conjunction commutes
          (x ^ y) > (y ^ x),

          # disjunction commutes
          (x | y) > (y | x),

          # detachment..
          (x ^ y) > y,

          # introduction..
          # x > (x | y),

          all(x).are(y) > some(x).are(y),
        ]
      end

      def rewrite_three_variables(x,y,z)
        [
          # conjunction associates
          ( x ^ (y ^ z) ) > ( (x ^ y) ^ z ),

          # disjunction associates
          ( x | (y | z) ) > ( (x | y) | z),

          # conjunction distributes over disjunction
          (x ^ (y | z)) > ((x ^ y) | (x ^ z)),

          # disjunction distributes over conjunction
          (x | (y ^ z)) > ((x | y) ^ (x | z))
        ]
      end
    end
  end
end
