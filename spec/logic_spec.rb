require 'spec_helper'
require 'pry'
require 'logic'

describe Logic do
  # cf https://en.wikipedia.org/wiki/Boolean_algebra#Laws
  let(:x) { Variable.new('x') }
  let(:y) { Variable.new('y') }
  let(:z) { Variable.new('z') }

  context 'according to the monotone laws:' do
    describe 'conjunction' do
      it 'has an identity (true)' do
        expect(x.conjoin(y).bind(y: true).reduce).to eq(x.to_expression)
      end

      it 'has an annihilator (false)' do
        expect(x.conjoin(y).bind(y: false).reduce).to eq(Falsity.to_expression)
      end

      it 'is associative' do
        expect(x.conjoin(y.conjoin(z))).to eq((x.conjoin(y)).conjoin(z))
      end

      it 'is commutative' do
        expect(x.conjoin(y)).to eq(y.conjoin(x))
      end

      it 'is idempotent' do
        expect(x.conjoin(x).reduce).to eq(x.to_expression)
      end

      it 'is distributive over disjunction' do
        expect(x.conjoin(y.disjoin(z))).to eq((x.conjoin(y)).disjoin(x.conjoin(z)))
      end

      it 'absorbs disjunctions' do
        expect(x.conjoin(x.disjoin(y)).reduce).to eq(x.to_expression)
      end
    end

    describe 'disjunction' do
      it 'has an identity (false)' do
        expect(x.disjoin(y).bind(y: false).reduce).to eq(x.to_expression)
      end

      it 'has an annihilator (true)' do
        expect(x.disjoin(y).bind(y: true).reduce).to eq(Truth.to_expression)
      end

      it 'is associative' do
        expect(x.disjoin(y.disjoin(z))).to eq((x.disjoin(y)).disjoin(z))
      end

      it 'is idempotent' do
        expect(x.disjoin(x).reduce).to eq(x.to_expression)
      end

      it 'is commutative' do
        expect(x.disjoin(y)).to eq(y.disjoin(x))
      end

      it 'is distributive over conjunction' do
        expect(x.disjoin(y.conjoin(z))).to eq((x.disjoin(y)).conjoin(x.disjoin(z)))
      end

      it 'absorbs conjunctions' do
        expect(x.disjoin(x.conjoin(y)).reduce).to eq(x.to_expression)
      end
    end
  end
end

describe Term do
  describe Constant do
    it 'always has a standard truth-functional value' do
      expect(Truth.value).to be_truthy
      expect(Falsity.value).to be_falsy
    end

    let(:not_true) { Truth.negate }

    it 'can be negated' do
      expect(not_true).to be_an(Expression)
      expect(not_true.name).to eq('~T')
      expect(not_true.describe).to eq('not T')
      expect(not_true.evaluate).to be_falsy
    end
  end

  describe Variable do
    let(:a) { Variable.new('a') }
    let(:not_a) { a.negate }
    let(:b) { Variable.new('b') }
    let(:a_and_b) { a.conjoin(b) }
    let(:b_and_a) { b.conjoin(a) }
    let(:a_or_b) { a.disjoin(b) }
    let(:b_or_a) { b.disjoin(a) }
    let(:a_then_b) { a.implies(b) }
    let(:b_then_a) { b.implies(a) }

    it 'has an placeholder truth-functional value' do
      expect(a.name).to eq('a')
      expect(a.to_expression.evaluate(a: true)).to be_truthy
      expect(a.to_expression.evaluate(a: false)).to be_falsy
    end

    it 'can be negated' do
      expect(not_a).to be_an(Expression)
      expect(not_a.name).to eq('~a')
      expect(not_a.evaluate(a: true)).to be_falsy
      expect(not_a.evaluate(a: false)).to be_truthy
    end

    it 'can be conjoined' do
      expect(a_and_b.name).to eq('a^b')
      expect(b_and_a.name).to eq('b^a')

      expect(a_and_b.evaluate(a: true,  b: true)).to be_truthy
      expect(a_and_b.evaluate(a: true,  b: false)).to be_falsy
      expect(a_and_b.evaluate(a: false, b: true)).to be_falsy
      expect(a_and_b.evaluate(a: false, b: false)).to be_falsy

      expect(b_and_a.evaluate(a: true,  b: true)).to be_truthy
      expect(b_and_a.evaluate(a: true,  b: false)).to be_falsy
      expect(b_and_a.evaluate(a: false, b: true)).to be_falsy
      expect(b_and_a.evaluate(a: false, b: false)).to be_falsy
    end

    it 'can be disjoined' do
      expect(a_or_b.name).to eq('avb')
      expect(b_or_a.name).to eq('bva')

      expect(a_or_b.evaluate(a: true,  b: true)).to be_truthy
      expect(a_or_b.evaluate(a: true,  b: false)).to be_truthy
      expect(a_or_b.evaluate(a: false, b: true)).to be_truthy
      expect(a_or_b.evaluate(a: false, b: false)).to be_falsy

      expect(b_or_a.evaluate(a: true,  b: true)).to be_truthy
      expect(b_or_a.evaluate(a: true,  b: false)).to be_truthy
      expect(b_or_a.evaluate(a: false, b: true)).to be_truthy
      expect(b_or_a.evaluate(a: false, b: false)).to be_falsy
    end

    it 'can be implicated' do
      expect(a_then_b.name).to eq('a->b')
      expect(b_then_a.name).to eq('b->a')

      expect(a_then_b.evaluate(a: true,  b: true)).to be_truthy
      expect(a_then_b.evaluate(a: true,  b: false)).to be_falsy
      expect(a_then_b.evaluate(a: false, b: true)).to be_truthy
      expect(a_then_b.evaluate(a: false, b: false)).to be_truthy

      expect(b_then_a.evaluate(a: true,  b: true)).to be_truthy
      expect(b_then_a.evaluate(a: true,  b: false)).to be_truthy
      expect(b_then_a.evaluate(a: false, b: true)).to be_falsy
      expect(b_then_a.evaluate(a: false, b: false)).to be_truthy
    end
  end

  describe Expression do
    let(:a_prime) { Variable.new('a') }
    let(:a) { SimpleExpression.new(a_prime) }

    let(:b_prime) { Variable.new('b') }
    let(:b) { SimpleExpression.new(b_prime) }

    it 'can be narrated' do
      expect(a.describe).to eq("a")
      expect(a.negate.describe).to eq("not a")
      expect(a.conjoin(a).describe).to eq("a and a")
      expect(a.disjoin(a).describe).to eq("a or a")
      expect(a.implies(a).describe).to eq("a then a")

      expect(b.describe).to eq("b")
      expect(b.implies(a.negate.conjoin(b)).describe).to eq("b then (not a and b)")
    end

    it 'can identify free variables' do
      expect(a.free_variables).to eq([a_prime])
      expect(b.free_variables).to eq([b_prime])

      expect(a.implies(b).free_variables).to eq([a_prime, b_prime])
      expect(a.negate.implies(b.conjoin(a.disjoin(b))).free_variables).to eq([a_prime, b_prime])
    end

    it 'can bind variables' do
      expect(a.bind(a: false).evaluate).to eq(false)
      expect(b.bind(b: true).evaluate).to eq(true)
    end

    it 'can be satisfied' do
      expect(a.satisfiable?).to eq(true)
      expect(a.conjoin(a.negate).satisfiable?).to eq(false)
    end

    it 'can identify satisfying cases' do
      expect(a.satisfiers).to eq([{a: true}])
      expect(a.conjoin(a.negate).satisfiers).to eq([])
      expect(a.implies(b).negate.satisfiers).to eq([{a: true, b: false}])
      expect(a.disjoin(b).satisfiers).to eq([{a: true, b: true}, {a: true, b: false}, {a: false, b: true}])
    end
  end
end
