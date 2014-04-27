require_relative "../rv2da_jsonobject"

class RGSS3::Color
  def initialize(red, green, blue, alpha)
    @red = red
    @green = green
    @blue = blue
    @alpha = alpha
  end

  def _dump(limit)
    [@red, @green, @blue, @alpha].pack("E4")
  end

  def self._load(obj)
    Color.new(*obj.unpack("E4"))
  end
end

class Color < RGSS3::Color
  include Rv2da::JsonObject
end
