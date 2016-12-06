require 'spec_helper'

describe ConstantExpression do
  it 'always has a standard truth-functional value' do
    expect(Truth.value).to be_truthy
    expect(Falsity.value).to be_falsy
  end

  let(:not_true) { Truth.negate }

  it 'can be negated' do
    expect(not_true).to be_an(Expression)
    expect(not_true.name).to eq('~T')
    expect(not_true.describe).to eq('(not T)')
    expect(not_true.evaluate).to be_falsy
  end
end
