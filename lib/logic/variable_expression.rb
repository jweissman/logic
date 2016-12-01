module Logic
  class VariableExpression < Expression
    def initialize(name)
      @name = name
    end

    def name
      @name
    end

    def describe
      @name
    end

    def free_variables
      [@name]
    end

    def evaluate(env={})
      raise "Env (#{env}) does not contain term #{term.name}" unless env.include?(name.to_sym)
      env[name.to_sym]
    end

    def lift_bool(b)
      b ? Truth : Falsity
    end

    private
    attr_reader :term
  end
end
