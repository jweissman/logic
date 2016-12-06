module Logic
  class QuantifiedExpression < Expression
    attr_reader :subject, :predicate, :affirmative

    def initialize(subject, predicate, affirmative: true)
      @subject = subject
      @predicate = predicate
      @affirmative = affirmative
    end

    def free_variables
      @expression.free_variables
    end

    def negative?
      !@affirmative
    end
  end

  class UniversalExpression < QuantifiedExpression
    def name
      "{A<x>.#{subject}[<x>]->#{negative? ? '~' : ''}#{predicate}[<x>]}"
    end

    def describe
      if negative?
        "no #{subject}s are #{predicate}s"
      else
        "all #{subject}s are #{predicate}s"
      end
    end
  end

  class ExistentialExpression < QuantifiedExpression
    def name
      "{E<x>.##{subject}[x]->#{negative? ? '~' : ''}#{predicate}[<x>]}"
    end

    def describe
      if negative?
        "some #{subject}s are not #{predicate}s"
      else
        "some #{subject}s are #{predicate}s"
      end
    end
  end

  class IndefiniteExpression < QuantifiedExpression
    def name
      "{#{negative? ? '~' : ''}#{predicate}[#{subject}]}"
    end

    def describe
      if negative?
        "#{subject} is not #{predicate}"
      else
        "#{subject} is #{predicate}"
      end
    end
  end

  # we could differentiate singular/indefinite but it's all just 'expressions' really

  class QuantifierBuilder
    def initialize(klass, predicate, negate: false)
      @klass = klass
      @predicate = predicate
      @negate = negate
    end

    def are(expression)
      @klass.new(@predicate, expression, affirmative: !@negate)
    end
  end
end
