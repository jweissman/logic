require 'logic/version'
require 'logic/satisfaction'
require 'logic/reduction'
require 'logic/expression'
require 'logic/constant_expression'
require 'logic/variable_expression'
require 'logic/negated_expression'
require 'logic/bound_expression'
require 'logic/binary_expression'
require 'logic/conjoined_expression'
require 'logic/disjoined_expression'
require 'logic/conditional_expression'
require 'logic/biconditional_expression'
require 'logic/axioms'
require 'logic/predicate_expression'
require 'logic/quantified_expression'
require 'logic/simple_object_expression'
require 'logic/environment'

module Logic
  Truth = ConstantExpression.new("T", true).freeze
  Falsity = ConstantExpression.new("F", false).freeze

  def prelude!
    @_prelude = {}
    %w[ a b c d t u v w x y z ].map { |letter| define_method(letter.to_sym) { @_prelude[letter] ||= VariableExpression.new(letter) } } #method(:new))
  end
end
