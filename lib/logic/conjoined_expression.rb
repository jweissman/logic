module Logic
  class ConjoinedExpression < BinaryExpression
    def evaluate(env={})
      @left.evaluate(env) && @right.evaluate(env)
    end

    def operator_glyph
      '^'
    end

    def operator_description
      'and'
    end
  end
end
