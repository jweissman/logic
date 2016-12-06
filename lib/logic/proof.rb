module Logic
  module Proof
    # an organized set of propositions, organized by implication
    class Node
      def initialize()
      end
    end

    class Knowledge
      def initialize(root_thesis)
        @root = Node.new(root_thesis)
      end

      def grow
      end
    end

    # class Thesis
    #   def initialize()
    #   end
    # end

    class << self
      def establish(premise, conclusion)
        knowledge = [ premise ]

        depth = 2
        depth.times do |i|
          p [ depth: i, brain_size: knowledge.size, knowledge: knowledge ]
          knowledge = grow knowledge
          break if knowledge.include?(conclusion)
        end

        # can premise reduce/rewrite to conclusion?
        knowledge.include?(conclusion)
      end

      def grow(knowledge)
        (knowledge + implications_of(knowledge)).uniq
      end

      def implications_of(knowledge)
        knowledge.flat_map do |article|
          article.rewrite
        end
      end
    end
  end
end
