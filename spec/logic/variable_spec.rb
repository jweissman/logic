require 'spec_helper'

describe VariableExpression do
  let(:a) { VariableExpression.new('a') }
  let(:b) { VariableExpression.new('b') }
  let(:not_a) { a.negate }
  let(:a_and_b) { a.conjoin(b) }
  let(:b_and_a) { b.conjoin(a) }
  let(:a_or_b) { a.disjoin(b) }
  let(:b_or_a) { b.disjoin(a) }
  let(:a_then_b) { a.implies(b) }
  let(:b_then_a) { b.implies(a) }

  it 'has an placeholder truth-functional value' do
    expect(a.name).to eq('a')
    expect(a.evaluate(a: true)).to be_truthy
    expect(a.evaluate(a: false)).to be_falsy
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

