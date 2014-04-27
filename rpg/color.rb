require_relative "../rv2da_jsonobject"

class Color
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

  alias initialize_org_json_object initialize
  include Rv2da::JsonObject
  def initialize(*args); initialize_from_json_object(*args); end
end
