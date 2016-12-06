require 'rspec'
require 'pry'
require 'logic'

include Logic

# an exemplary 'discursive object' in the domain of discourse
# the important features being that it's *not* a "logic" object
# (but rather something anyone can make/use and be compatible with logic)
# and that it responds to #name
class DiscursiveObject < Struct.new(:name)
end

class Person < DiscursiveObject
end

class Deity < DiscursiveObject
end

VALID_FORMS = %w[ aaa aii aoo aee eio oao ]

def syllogisms_for(a,b,c)
  VALID_FORMS.map { |form| form_to_syllogism(form, a, b, c) }
end

def form_to_syllogism(form, a, b, c)
  major, minor, conclusion = *(form.split(''))
  ( letter_to_expression(major, a, b) ^ (letter_to_expression(minor, b, c) ) ).implies( letter_to_expression(conclusion, a, c) )
end

def letter_to_expression(letter, x, y)
  case letter
  when 'a' then Logic.all(x).are(y)
  when 'e' then Logic.no(x).are(y)
  when 'i' then Logic.some(x).are(y)
  when 'o' then Logic.not_all(x).are(y)
  else raise "implement quantified expression for letter #{letter}"
  end
end
