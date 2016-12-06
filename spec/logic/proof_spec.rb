require 'spec_helper'

describe Proof do
  context 'demonstrate truth/falsity of a proposition' do
    let(:a) { VariableExpression.new('a') }
    let(:b) { VariableExpression.new('b') }
    let(:c) { VariableExpression.new('c') }

    xit 'should identify reduction steps for MP' do
      proposition = (a > b) ^ a
      conclusion = b
      proof = proposition.prove(conclusion) #implies(conclusion).prove

      expect( proof.steps ).to eq(
        [
          [ given: proposition, reduce: conclusion ]
        ]
      )
    end

    xit 'should identify rewriting steps' do
      proposition = ((a ^ a) > (b ^ b)) ^ (~~(a ^ a))
      conclusion = b
      proof = proposition.prove(b)

      expect( proof.steps ).to eq(
        [
          [ given: proposition , reduce: conclusion ]
        ]
      )
    end

    xit 'should identify rewriting steps for a more complex expression' do
      proposition = (Logic.all(a).are(b) ^ some(b).are(c))
      conclusion = some(a).are(c)
      proof = proposition.prove(conclusion) #implies(conclusion).prove
      expect(proof.steps).to eq([
        [ given: proposition ]
      ])
    end
  end
end
