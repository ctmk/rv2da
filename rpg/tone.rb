require_relative "../rv2da_jsonobject"

class RGSS3::Tone
  def initialize(red, green, blue, gray = nil)
    @red = red
    @green = green
    @blue = blue
    @gray = gray
  end

  def _dump(limit)
    [@red, @green, @blue, @gray].pack("E4")
  end

  def self._load(obj)
    Tone.new(*obj.unpack("E4"))
  end
end

class Tone < RGSS3::Tone
  include Rv2da::JsonObject
end
