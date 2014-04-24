require "./JsonUtility"

class Table
  def initialize(data)
    @dimension, @xsize, @ysize, @zsize, @num_elements, *elements = *data

    @elements = ([@xsize||1, @ysize||1].slice(0, @dimension-1) || []).inject(elements) do|memo, size|
      memo.each_slice(size > 0 ? size : 1).to_a
    end
  end

  def _dump(limit)
    [@dimension, @xsize, @ysize, @zsize, @num_elements, *@elements.flatten].pack("V5v*")
  end

  def self._load(obj)
    Table.new(obj.unpack("V5v*"))
  end

  alias initialize_org_json_utility initialize
  include JsonUtility
  def initialize(*args); initialize_from_json_object(*args); end
end
