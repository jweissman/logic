module Logic
  class BinaryExpression < Expression
    attr_reader :left, :right

    def initialize(left, right)
      raise unless left.is_a?(Expression) && right.is_a?(Expression)
      @left = left
      @right = right
    end

    def name
      "#{parenthesize @left.name}#{operator_glyph}#{parenthesize @right.name}"
    end

    def describe
      "#{parenthesize @left.describe} #{operator_description} #{parenthesize @right.describe}"
    end

    def free_variables
      (@left.free_variables + @right.free_variables).uniq.sort
    end

    def operator_glyph
      raise "override #operator_glyph in #{self.class.name}"
    end

    def operator_description
      raise "override #operator_description in #{self.class.name}"
    end
  end
end
