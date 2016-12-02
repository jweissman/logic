module Logic
  class DisjoinedExpression < BinaryExpression
    def operator_glyph
      'v'
    end

    def operator_description
      'or'
    end
  end
end
