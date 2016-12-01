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
    expect(a.bind(a: false).evaluate).to eq(false)
    expect(b.bind(b: true).evaluate).to eq(true)
    expect(a.conjoin(b).bind(a: true, b: true).evaluate).to eq(true)
    expect(a.conjoin(b).bind(a: true, b: false).evaluate).to eq(false)
  end

  it 'can be satisfied' do
    expect(a.satisfiable?).to eq(true)
    expect(a.conjoin(a.negate).satisfiable?).to eq(false)
  end

  it 'can identify satisfying cases' do
    expect(a.solve).to eq([{a: true}])
    expect(a.conjoin(a.negate).solve).to eq([])
    expect(a.implies(b).negate.solve).to eq([{a: true, b: false}])
    expect(a.disjoin(b).solve).to eq([{a: true, b: true}, {a: true, b: false}, {a: false, b: true}])
  end
end
