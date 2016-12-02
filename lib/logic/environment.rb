module Logic
  # class Environment
  #   def initialize
  #     @propositions = []
  #   end

  #   def inform(prop)
  #     @propositions.push(prop)
  #   end

  #   def query(expr)
  #     @propositions.reduce(&:conjoin).implies(expr).evaluate
  #   end

  #   def self.current
  #     @current_env ||= Environment.new
  #   end
  # end
end
