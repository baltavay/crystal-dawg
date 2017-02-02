module Dawg
  abstract class AbstractNode
    @final = false
    property :final
    abstract def [](letter : Char)
    def each_edge(&block)
    end
  end
end
