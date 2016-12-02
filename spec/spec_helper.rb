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
