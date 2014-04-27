require_relative "../rv2da_jsonobject"

class Table
  def initialize(data)
    @dimension, @xsize, @ysize, @zsize, @num_elements, *elements = *data

    xsize = [@xsize, 1].compact.max
    ysize = [@ysize, 1].compact.max
    dimension = [@dimension, 1].compact.max
    
    @elements = [xsize, ysize].take(dimension - 1).inject(elements) do|memo, size|
      memo.each_slice(size).to_a
    end
  end

  def _dump(limit)
    [@dimension, @xsize, @ysize, @zsize, @num_elements, *@elements.flatten].pack("V5v*")
  end

  def self._load(obj)
    Table.new(obj.unpack("V5v*"))
  end

  alias initialize_org_json_object initialize
  include Rv2da::JsonObject
  def initialize(*args); initialize_from_json_object(*args); end
end
