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
        expect(a_then_b_then_c.reduce).to eq(a_and_b_then_c)
      end
    end

    describe "(a > b) ^ a -> b" do
      let (:a_then_b_and_a) { (a > b) ^ a }
      it 'should resolve implication via conjunction' do
        expect(a_then_b_and_a.reduce).to eq(b)
      end
    end
  end
end
