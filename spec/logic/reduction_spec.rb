require 'spec_helper'

include Reduction
describe Reduction do
  context 'rewrite rules' do
    let(:a) { VariableExpression.new('a') }
    let(:b) { VariableExpression.new('b') }
    let(:c) { VariableExpression.new('c') }

    describe "~~a -> a" do
      let(:not_not_a) { ~~a }
      it 'should involute complementation' do
        expect(not_not_a.reduce).to eq(a)
      end
    end

    describe "a > b > c -> (a ^ b) > c" do
      let(:a_then_b_then_c) { a > b > c }
      let(:a_and_b_then_c)  { (a ^ b) > c }

      it 'should curry conditionals' do
        expect(simplify(a_then_b_then_c)).to eq(a_and_b_then_c)
      end
    end

    describe "(a > b) ^ a -> b" do
      let (:a_then_b_and_a) { (a > b) ^ a }
      it 'should resolve implication via conjunction' do
        expect(simplify(a_then_b_and_a)).to eq(b)
      end

      # it 'should resolve implication via binding' do
      #   expect(simplify(a > b, a: true)).to eq(b)
      # end

      # does this even make sense?
      # the idea is to support other annihilation/identity reductions
      # since this proposition can't be relevant to deduction anymore, can it?????????
      # unless we're trying to derive contradictions?
      # let's roll with it
      # it 'should not collapse failed implications even if bound false' do
      #   expect(simplify(a > b, a: false)).to eq(a > b)
      # end
    end
  end
end
