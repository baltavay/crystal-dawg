module Dawg
  class DawgIO
    include IO
    FORMAT = IO::ByteFormat::LittleEndian
    NODE_START = 8
    NODE_SIZE = 17
    EDGE_SIZE = 12
    @node_count : Int32
    @edge_count : Int32
    property :slice, :node_count, :edge_count
    def initialize(@slice : Bytes)
      @node_count = get_node_count
      @edge_count = get_edge_count
    end

    def read(slice : Bytes)
      slice.size.times { |i| slice[i] = @slice[i] }
      @slice += slice.size
      slice.size
    end

    def write(slice : Bytes)
      slice.size.times { |i| @slice[i] = slice[i] }
      @slice += slice.size
      nil
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

      NodeIO.new(self, index, edge_count, final, hash, edges_pos)
    end

    def each_node(&block)
      (1..@node_count).each do |index|
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
      node = get_node_by_index(@node_count - 1)
      results = [] of Word
      word.split("").each do |letter|
        next_node = node[letter[0]]
        if next_node != nil
          node = next_node.not_nil!
          next
        else
          return [""]
        end
      end

      results << Word.new(word, node.final)
      results += get_childs(node).map{|s| Word.new(word) + s}
      results.select{|r| r.final}.map{|r| r}
    end

    def query_first(word)
      node = get_node_by_index(@node_count - 1)
      results = [] of Word
      word.split("").each do |letter|
        next_node = node[letter[0]]
        if next_node != nil
          node = next_node.not_nil!
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
      node = node.not_nil!
      node.each_edge do |hash, char|
        next_node = node[char].not_nil!
        results += get_childs(next_node).map{|s| Word.new(char) + s}
        results << Word.new(char, next_node.final)
      end
      results
    end

    def self.load(filename)
      data = [] of UInt8
      File.open(filename) do |f|
        f.each_byte do |byte|
          data << byte
        end
      end
      ptr = data.to_unsafe
      DawgIO.new(ptr.to_slice(data.size * sizeof(UInt32)))
    end

  end

end
