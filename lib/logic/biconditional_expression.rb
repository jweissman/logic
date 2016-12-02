module Logic
  class BiconditionalExpression < BinaryExpression
    def operator_glyph
      '<->'
    end

    def operator_description
      'iff'
    end
  end
end
