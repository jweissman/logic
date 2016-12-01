module Logic
  class DisjoinedExpression < BinaryExpression
    def evaluate(env={})
      @left.evaluate(env) || @right.evaluate(env)
    end

    def operator_glyph
      'v'
    end

    def operator_description
      'or'
    end
  end
end
