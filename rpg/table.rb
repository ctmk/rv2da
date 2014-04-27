require_relative "../rv2da_jsonobject"

class RGSS3::Table
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
end

class Table < RGSS3::Table
  include Rv2da::JsonObject
end
