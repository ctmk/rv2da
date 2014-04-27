require_relative "../rv2da_jsonobject"

class Tone
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

  alias initialize_org_json_object initialize
  include Rv2da::JsonObject
  def initialize(*args); initialize_from_json_object(*args); end
end
