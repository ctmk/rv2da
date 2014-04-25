require_relative "../JsonUtility"

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

  alias initialize_org_json_utility initialize
  include JsonUtility
  def initialize(*args); initialize_from_json_object(*args); end
end
