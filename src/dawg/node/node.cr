module Dawg
  class Node < AbstractNode
    @@next_id = 0
    @id = 0
    property :edges, :id, :edge_count, :index

    def initialize(@id = @@next_id, @final = false, @edge_count = 0, @index = -1)
      @@next_id += 1
      @edges = {} of Char => Node
    end

    def to_s
      arr = [] of String
      if @final
          arr<<"1"
      else
          arr<<"0"
      end

      @edges.each do |label,node|
          arr << label.to_s
          arr << node.id.to_s
      end

      arr.join("_")

    end

    def hash
      to_s.hash
    end

    def ==(other)
      to_s == other.to_s
    end

    def [](letter : Char)
      @edges[letter]
    end

    def each_edge(&block)
      @edges.each do |letter, node|
        yield letter
      end
    end
  end

end
