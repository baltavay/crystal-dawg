require "./dawg/node/*"
require "./dawg/finder"
require "./dawg/dawg/*"
require "./dawg/*"

module Dawg
  VERSION = "0.1.0"

  FORMAT = IO::ByteFormat::LittleEndian
  NODE_START = 8
  NODE_SIZE = 17
  EDGE_SIZE = 12

  enum Type
    Fast # fast but eats memory
    Small # slower but dont eats memory
  end

  extend self

  def create
    Dawg.new
  end

  def load(filename : String, type : Type)
    case type
    when Type::Fast
      Serialization.load_fast(filename)
    when Type::Small
      Serialization.load_small(filename)
    else
      Serialization.load_small(filename)
    end
  end

  def save(filename : String, dawg : Dawg)
    Serialization.save(filename, dawg)
  end
end
