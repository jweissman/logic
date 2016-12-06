require 'logic/version'
require 'logic/expression_helper'
require 'logic/satisfaction'
require 'logic/reduction'
require 'logic/evaluation'
require 'logic/rewriting'
require 'logic/proof'
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

module Logic
  Truth = ConstantExpression.new("T", true).freeze
  Falsity = ConstantExpression.new("F", false).freeze
  Unprovable = ConstantExpression.new("<<unprovable>>", -0.01).freeze

  def prelude!
    @_prelude = {}
    %w[ a b c d t u v w x y z ].map { |letter| define_method(letter.to_sym) { @_prelude[letter] ||= VariableExpression.new(letter) }} #method(:new))
    %w[ human mortal philosopher deity ].map { |predicate| define_method(predicate.to_sym) { @_prelude[predicate] ||= PredicateExpression.new(predicate) }}
  end

  def all(predicate)
    QuantifierBuilder.new(UniversalExpression, predicate)
  end

  def some(predicate)
    QuantifierBuilder.new(ExistentialExpression, predicate)
  end

  def no(predicate)
    QuantifierBuilder.new(UniversalExpression, predicate, negate: true)
  end

  def not_all(predicate)
    QuantifierBuilder.new(ExistentialExpression, predicate, negate: true)
  end
end
