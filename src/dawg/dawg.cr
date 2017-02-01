module Dawg
  class Dawg
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

    def query(word)
      node = @root
      results = [] of Word
      word.split("").each_with_index do |letter, index|

        if node.edges[letter[0]]?
          node = node.edges[letter[0]]

          next
        else
          return [""]
        end
      end

      results << Word.new(word, node.final)
      results += get_childs(node).map{|s| Word.new(word) + s}
      results.select{|r| r.final}.map{|r| r}
    end

    def get_childs(node)
      results = [] of Word
      node.edges.keys.each_with_index do |letter, index|
        results += get_childs(node.edges[letter]).map{|s| Word.new(letter) + s}
        results << Word.new(letter, node.edges[letter].final)
      end
      results
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


    def save(filename)
      File.open(filename,"w") do |f|
        write_int(node_count, f) # overall nodes count
        write_int(edge_count, f) # overall edge count
        edges_pos = 0
        @minimized_nodes.each do |hash, node|
          write_int(edges_pos, f)
          write_int(node.edges.keys.size, f)
          write_int(node.id, f)
          write_bool(node.final, f)
          write_int(hash, f)
          edges_pos += 12 * node.edges.keys.size # position of node's edges in a file
        end
        @minimized_nodes.each do |hash, node|
          node.edges.each do |letter, n|
            write_int(n.hash, f)
            write_char(letter, f)
            write_int(n.index,f)
          end
        end
      end
    end

    def self.load(filename)
      dawg = Dawg.new
      File.open(filename) do |f|
        minimized_nodes_count = load_int(f)
        overall_edges_count = load_int(f)
        minimized_nodes_count.times do
          edges_pos = load_int(f)
          edge_count = load_int(f)
          id = load_int(f)
          final = load_bool(f)
          hash = load_int(f)
          node = Node.new(id: id, final: final, edge_count: edge_count)
          dawg.minimized_nodes[hash] = node
        end
        
        dawg.minimized_nodes.each do |hash, node|
          node.edge_count.times do
            hash2 = load_int(f)
            letter = load_char(f).not_nil!
            node_index = load_int(f)
            node.edges[letter] = dawg.minimized_nodes[hash2]
          end
        end
        root_key = dawg.minimized_nodes.keys.last
        dawg.minimized_nodes[root_key].edges.each do |letter, node|
          dawg.root.edges[letter] = node
        end
      end
      dawg
    end
  end
end
