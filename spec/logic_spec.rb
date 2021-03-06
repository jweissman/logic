require 'spec_helper'

describe Logic do
  # cf https://en.wikipedia.org/wiki/Boolean_algebra#Laws
  let(:x) { VariableExpression.new('x') }
  let(:y) { VariableExpression.new('y') }
  let(:z) { VariableExpression.new('z') }

  context 'follows monotone laws:' do
    describe 'conjunction' do
      it 'has an identity (Truth)' do
        expect(x.conjoin(Truth).reduce).to eq(x)
      end

      it 'has an annihilator (False)' do
        expect(x.conjoin(Falsity).reduce).to be(Falsity)
      end

      it 'is associative' do
        expect(x.conjoin(y.conjoin(z))).to match (x.conjoin(y)).conjoin(z)
      end

      it 'is commutative' do
        expect(x.conjoin(y)).to match (y.conjoin(x))
      end

      it 'is idempotent' do
        expect(x.conjoin(x).reduce).to eq(x)
      end

      it 'is distributive over disjunction' do
        expect(x.conjoin(y.disjoin(z))).to match((x.conjoin(y)).disjoin(x.conjoin(z)))
      end

      it 'absorbs disjunctions' do
        expect(x.conjoin(x.disjoin(y)).reduce).to eq(x)
      end
    end

    describe 'disjunction' do
      it 'has an identity (False)' do
        expect(x.disjoin(Falsity).reduce).to eq(x)
      end

      it 'has an annihilator (True)' do
        expect(x.disjoin(Truth).reduce).to be(Truth)
      end

      it 'is associative' do
        expect(x.disjoin(y.disjoin(z))).to match((x.disjoin(y)).disjoin(z))
      end

      it 'is idempotent' do
        expect(x.disjoin(x).reduce).to eq(x)
      end

      it 'is commutative' do
        expect(x.disjoin(y)).to match(y.disjoin(x))
      end

      it 'is distributive over conjunction' do
        expect(x.disjoin(y.conjoin(z))).to match((x.disjoin(y)).conjoin(x.disjoin(z)))
      end

      it 'absorbs conjunctions' do
        expect(x.disjoin(x.conjoin(y)).reduce).to eq(x)
      end
    end
  end

  context 'follows non-monotone laws:' do
    describe 'complementation' do
      it 'resolves to falsity under conjunction' do
        expect(x.conjoin(x.negate).reduce).to be(Falsity)
      end

      it 'resolves to truth under disjunction' do
        expect(x.disjoin(x.negate).reduce).to be(Truth)
      end

      it 'involutes' do
        expect(x.negate.negate.reduce).to eq(x)
      end

      it 'follows De Morgan' do
        expect((x.negate).conjoin(y.negate)).to match(x.disjoin(y).negate)
        expect((x.negate).disjoin(y.negate)).to match(x.conjoin(y).negate)
      end
    end
  end

  context 'material implication' do
    it 'resolves with conjunction of antecedent' do
      expect(x.implies(y).conjoin(x).reduce).to eq(y)
    end

    it 'is curried' do
      expect(x.implies(y).implies(z).reduce).to eq(x.conjoin(y).implies(z))
    end
  end

  context 'biconditionals' do
    it 'have the expected truth table' do
      expect(x.iff(y).solve).to eq([{x: true, y: true}, {x: false, y: false}])
    end

    it 'are commutative' do
      expect(x.iff(y)).to match(y.iff(x))
    end
  end

  # these have become intolerably slow
  xcontext 'symbolic analysis' do
    let(:a) { VariableExpression.new('a') }
    let(:b) { VariableExpression.new('b') }
    let(:c) { VariableExpression.new('c') }

    xit 'should reduce subexpressions according to axioms' do
      bc = b ^ c
      yz = y | z

      expect(((bc > yz) ^ bc).reduce).to eq(yz)
    end

    xit 'should reduce inner expressions' do
      bx = b ^ x
      cy = c | y
      expect((~~(bx > cy) ^ bx).reduce).to eq(cy)
    end
  end

  context 'predication and quantification' do
    let(:human) { SimpleObjectExpression.new('human') }
    let(:mortal) { SimpleObjectExpression.new('mortal') }
    let(:philosopher) { SimpleObjectExpression.new('philosopher') }

    let(:socrates) do
      SimpleObjectExpression.new('socrates')
    end

    # should be tautological and follow symbolically as long as `human[socrates]` is an expression
    # basically a wiring test
    it 'realizes a predicate implies itself (like anything else)' do
      expect(socrates.is_a(human).implies(socrates.is_a(human)))
    end

    it 'should infer that socrates is a mortal' do
      major = Logic.all(human).are(mortal)
      minor = socrates.is_a(human)
      conclusion = socrates.is_a(mortal)

      syllogism = (major ^ minor).implies(conclusion)
      expect( syllogism.reduce ).to eq(Truth)
    end

    # okay, here we go :)
    context 'quantified syllogies' do
      it 'should resolve a fully quantified syllogism' do
        major = Logic.all(human).are(philosopher)
        minor = Logic.all(philosopher).are(mortal)
        conclusion = Logic.all(human).are(mortal)

        syllogism = (major ^ minor).implies(conclusion)
        expect( syllogism.reduce ).to eq(Truth)
      end

      let(:valid_syllogisms) do
        syllogisms_for(human, philosopher, mortal)
      end

      xit 'should resolve all valid syllogism forms' do
        valid_syllogisms.each do |syllogism|
          p [ syllogism: syllogism ]
          # binding.pry
          # binding.pry unless syllogism.reduce == Truth
          expect( syllogism.prove).to eq(Truth)
        end
      end
    end
  end
end
