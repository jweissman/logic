module Logic
  class ConjoinedExpression < BinaryExpression
    def operator_glyph
      '^'
    end

    def operator_description
      'and'
    end
  end
end
