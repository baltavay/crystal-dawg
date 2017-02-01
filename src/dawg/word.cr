module Dawg
  class Word
    @final : Bool
    @word : String
    property :final, :word
    def initialize( @word = "", @final = false);  end
    
    def initialize( char : Char, @final = false)
      @word = ""
      @word += char
    end

    def +(other : Tuple(String, Bool))
      Word.new(@word + other[0], other[1])
    end

    def +(other : Word)
      Word.new(@word + other.word, other.final)
    end

    def +(other : String)
      Word.new(@word + other, false)
    end


    def inspect(io)
      io.write(@word.to_slice)
    end
  end

end
