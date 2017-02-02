module Dawg
  module Finder
    def lookup(word, node : AbstractNode)
      word.each_char do |letter|
        next_node = node[letter]
        if next_node != nil
          node = next_node.not_nil!
          next
        else
          return [""]
        end
      end
      node.final
    end

    # get all words with given prefix
    def query(word, node : AbstractNode)
      results = [] of Word
      word.each_char do |letter|
        next_node = node[letter]
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

    def get_childs(node : AbstractNode)
      results = [] of Word
      node = node.not_nil!
      node.each_edge do |letter|
        next_node = node[letter].not_nil!
        results += get_childs(next_node).map{|s| Word.new(letter) + s}
        results << Word.new(letter, next_node.final)
      end
      results
    end
  end

end
