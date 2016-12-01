module Logic
  class BiconditionalExpression < BinaryExpression
    def evaluate(env={})
      @left.implies(@right).conjoin(@right.implies(@left)).evaluate(env)
    end

    def operator_glyph
      '<->'
    end

    def operator_description
      'iff'
    end
  end
end
