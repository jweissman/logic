module Logic
  class ConditionalExpression < BinaryExpression
    def evaluate(env={})
      @left.negate.disjoin(@right).evaluate(env)
    end

    def operator_glyph
      '->'
    end

    def operator_description
      'then'
    end
  end
end
