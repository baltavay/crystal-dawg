module Dawg
  module Serialization
    extend self

    def save(filename, dawg : Dawg)
      File.open(filename,"w") do |f|
        write_int(dawg.node_count, f) # overall nodes count
        write_int(dawg.edge_count, f) # overall edge count
        edges_pos = 0
        dawg.minimized_nodes.each do |hash, node|
          write_int(edges_pos, f)
          write_int(node.edges.keys.size, f)
          write_int(node.id, f)
          write_bool(node.final, f)
          write_int(hash, f)
          edges_pos += EDGE_SIZE * node.edges.keys.size # position of node's edges in a file
        end
        dawg.minimized_nodes.each do |hash, node|
          node.edges.each do |letter, n|
            write_int(n.hash, f)
            write_char(letter, f)
            write_int(n.index,f)
          end
        end
      end
    end

    def load_fast(filename)
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

    def load_small(filename)
      File.open(filename) do |f|
        data = Bytes.new(f.size)
        f.read_fully(data)
        return MemoryDawg.new(data)
      end
    end

    def load_int(io)
      Int32.from_io(io, IO::ByteFormat::LittleEndian)
    end

    def write_int(int, io)
      int.to_io(io, IO::ByteFormat::LittleEndian)
    end

    def write_bool(var, io)
      io.write_byte( var ? 1_u8 : 0_u8)
    end

    def load_bool(io)
      byte = io.read_byte
      byte == 1_u8 ? true : false
    end

    def write_char(char, io)
      write_int(char.ord, io)
    end

    def load_char(io)
      load_int(io).unsafe_chr
    end
  end
end
