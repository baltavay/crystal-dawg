module Dawg
  class MemoryDawg
    include Finder
    @node_count : Int32
    @edge_count : Int32

    property :slice, :node_count, :edge_count

    def initialize(@slice : Bytes)
      @node_count = get_node_count
      @edge_count = get_edge_count
      @root = uninitialized AbstractNode
    end

    def root
      @root = get_node_by_index(@node_count - 1)
    end

    def get_node_count
      io = IO::Memory.new(@slice[0,4])
      Int32.from_io(io, FORMAT)
    end

    def get_edge_count
      io = IO::Memory.new(@slice[4,4])
      Int32.from_io(io, FORMAT)
    end

    def get_node_by_index(index)
      pos = NODE_START + NODE_SIZE * index
      edges_pos = get_int(@slice[pos, 4])
      pos += 4
      edge_count = get_int(@slice[pos, 4])
      pos += 4
      id = get_int(@slice[pos, 4])
      pos += 4
      final = get_bool(@slice[pos, 1])
      pos += 4
      hash = get_int(@slice[pos, 4])

      MemoryNode.new(self, index, edge_count, final, hash, edges_pos)
    end

    def each_node(&block)
      (0..@node_count).each do |index|
        pos = NODE_START + NODE_SIZE * index
        edges_pos = get_int(@slice[pos, 4])
        pos += 4
        edge_count = get_int(@slice[pos, 4])
        pos += 4
        id = get_int(@slice[pos, 4])
        pos += 4
        final = get_bool(@slice[pos, 1])
        pos += 4
        hash = get_int(@slice[pos, 4])
        yield edge_count, id, final, hash, index, edges_pos

      end

    end

    def each_edge(index, &block)
      edges_pos = get_int(@slice[NODE_START + NODE_SIZE * index, 4])
      edge_count = get_int(@slice[NODE_START + NODE_SIZE * index + 4, 4])
      edge_start = NODE_START + NODE_SIZE * @node_count
      position = edge_start + edges_pos
      edge_count.times do
        hash = get_int(@slice[position, 4])
        char = get_char(@slice[position + 4, 4])
        node_index = get_int(@slice[position + 8, 4])
        yield hash, char, node_index
        position += EDGE_SIZE
      end
    end

    def get_int(slice : Bytes)
      io = IO::Memory.new(slice)
      Int32.from_io(io, FORMAT)
    end

    def get_char(slice : Bytes)
      io = IO::Memory.new(slice)
      Int32.from_io(io, FORMAT).unsafe_chr
    end

    def get_bool(slice : Bytes)
      slice.to_a[0] == 1_u8
    end

    def query(word)
      query(word, root)
    end

    def lookup(word)
      lookup(word, root)
    end
  end

end
