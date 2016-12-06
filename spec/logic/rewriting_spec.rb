require 'spec_helper'

include Rewriting

describe Rewriting do
  context 'rewrite rules' do
    let(:a) { VariableExpression.new('a') }
    let(:b) { VariableExpression.new('b') }

    it 'should provide rewritings' do
      rewritings = (a^b).rewrite
      expect( rewritings ).not_to be_empty
      expect( rewritings ).not_to include( (a^b) )
      # rewritings.each do |rewriting|
      #   binding.pry unless rewriting.match(a^b)
      #   expect( rewriting ).to match( a^b )
      # end
    end

  end
end
