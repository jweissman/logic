require 'spec_helper'

describe Axioms do
  let(:a) { VariableExpression.new('a') }
  let(:b) { VariableExpression.new('c') }
  let(:c) { VariableExpression.new('b') }

  # axioms are logical truths
  it 'are coherent' do
    aggregate_failures "single variable axioms are coherent" do
      Axioms.single_variable(a).each do |axiom|
        expect(axiom.left.reduce).to eq(axiom.right) # ...
      end
    end

    aggregate_failures "two variables axioms are coherent" do
      Axioms.two_variable(a,b).each do |axiom|
        expect(axiom.left.reduce).to eq(axiom.right)
      end
    end
  end
end
