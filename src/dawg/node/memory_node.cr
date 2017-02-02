module Dawg
  class MemoryNode < AbstractNode
    property :index, :io, :edge_count, :final, :hash, :edges_pos
    def initialize(@io : MemoryDawg, @index : Int32, @edge_count : Int32, @final : Bool, @hash : Int32, @edges_pos : Int32)

    end

    def [](letter : Char)
      @io.each_edge @index do |hash, char, node_index|
        if letter == char
          return @io.get_node_by_index(node_index)
          break
        end
      end
      nil
    end

    def each_edge(&block)
      @io.each_edge @index do |hash, char|
        yield char
      end
    end
  end

end
