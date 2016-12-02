require 'spec_helper'

describe Expression do
  let(:a) { VariableExpression.new('a') }
  let(:b) { VariableExpression.new('b') }

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
    expect(a.free_variables).to eq(['a'])
    expect(b.free_variables).to eq(['b'])

    expect(a.implies(b).free_variables).to eq(%w[ a b ])
    expect(a.negate.implies(b.conjoin(a.disjoin(b))).free_variables).to eq(%w[ a b ])
  end

  it 'can bind variables' do
    expect(a.bind(a: false).evaluate.reduce).to eq(Falsity)
    expect(b.bind(b: true).evaluate.reduce).to eq(Truth)
    expect(a.conjoin(b).bind(a: true, b: true).evaluate.reduce).to eq(Truth)
    expect(a.conjoin(b).bind(a: true, b: false).evaluate.reduce).to eq(Falsity)
  end

  it 'can be satisfied' do
    expect(a.satisfiable?).to eq(true)
    expect(a.conjoin(a.negate).satisfiable?).to eq(false)
  end

  context 'identifying satisfying cases' do
    it 'can solve a simple single-variable expression' do
      expect(a.solve).to eq([{a: true}])
    end

    it 'can solve a tautologically-false single-variable expression' do
      expect(a.conjoin(a.negate).solve).to eq([])
    end

    it 'can solve a negated implication' do
      expect((a.implies(b)).negate.solve).to eq([{a: true, b: false}])
    end

    it 'can solve a disjunction' do
      expect(a.disjoin(b).solve).to eq([{a: true, b: true}, {a: true, b: false}, {a: false, b: true}])
    end
  end
end
