module Dawg
  class Dawg
    include Finder
    property :root, :minimized_nodes


    def initialize
      @root = Node.new
      @previous_word = ""
      @unchecked_nodes = [] of Tuple(Node, Char, Node)
      @minimized_nodes = {} of Int32 => Node

    end

    def add(word : String)
      raise "Error: Words must be inserted in alphabetical order." if word < @previous_word
      common_prefix = 0

      if !@previous_word.empty?
        (0..[word.size-1, @previous_word.size-1].min).each do |i|
          break if word[i] != @previous_word[i]
          common_prefix += 1
        end
      end
      minimize(common_prefix)

      if @unchecked_nodes.size == 0
        node = @root
      else
        node =  @unchecked_nodes[-1][2]
      end

      word.split("")[common_prefix..-1].each do |letter|
        next_node = Node.new
        node.edges[letter[0]] = next_node
        @unchecked_nodes << {node, letter[0], next_node}
        node = next_node
      end

      node.final = true
      @previous_word = word
    end

    def finish
      minimize(0)
      @minimized_nodes[@root.hash] = @root
    end

    def minimize(down)
      (@unchecked_nodes.size - 1).downto(down).each do |i|
        parent, letter, child = @unchecked_nodes[i]
        if @minimized_nodes[child.hash]?
          parent.edges[letter] = @minimized_nodes[child.hash]
        else
          child.index = @minimized_nodes.size
          @minimized_nodes[child.hash] = child

        end
        @unchecked_nodes.pop
      end
    end

    def node_count
      @minimized_nodes.size
    end

    def edge_count
      count = 0
      @minimized_nodes.each do |key,node|
        count += node.edges.size
      end
      count
    end

    def query(word)
      query(word, @root)
    end

    def lookup(word)
      lookup(word, @root)
    end


  end
end
