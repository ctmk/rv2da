=begin

Author: Nobu
=end

require "json"
require "find"
require "./JsonUtility"
require "./rpg"

module Rv2DataAssembler

  # rvdata2を読み込む
  # @return [Object]
  # @param [String] filename
  def load_rvdata2(filename)
    File.open(filename, "rb") {|f|
      Marshal.load(f)
    }
  end
  
  # JSONファイルを読み込む
  # @return [Object]
  # @param [String] filename
  def load_json(filename)
    JSON.restore(File.read(filename, :encoding => Encoding::UTF_8))
  end
  
  # rvdata2として出力する
  # @param [Object] obj
  # @param [String] filename
  def save_rvdata2(obj, filename)
    File.open(filename, "wb") {|f|
      Marshal.dump(obj, f)
    }
  end
  
  # JSONファイルとして出力する
  # @param [Object] obj
  # @param [String] filename
  # @note JSONファイルとして有効な形に変換されて出力される
  def save_json(obj, filename)
    File.write(filename, JSON.pretty_generate(obj)) if obj
  end
  
end

# rvdata2を分解する
class Decomposition
  extend Rv2DataAssembler 
  class << self
    
    def do_all(dirname, output, excludes = [])
      decompose_all_files_in_directory(dirname, output, excludes)
    end
    
    def do(filename, output, excludes = [])
      decompose(filename, output, excludes)
    end
  
    def decompose_all_files_in_directory(dirname, path_out, excludes = [])
      Find.find(dirname) do |filename|
        decompose(filename, path_out, excludes)
      end
    end
  
    def decompose(filename, path_out, excludes = [])
      return unless filename =~ /([\w]+)\.rvdata2/
      matched = $1
      return unless excludes.find {|pattern| matched.match(Regexp.compile(pattern)) }.nil?

      save_json(load_rvdata2(filename), "#{path_out}/#{matched}.json")
    end

  end
end

# rvdata2に変換する
class Composition
  extend Rv2DataAssembler
  class << self
    
    def do_all(dirname, output, excludes = [])
      compose_all_files_in_directory(dirname, output, excludes)
    end
    
    def do(filename, output, excludes = [])
      compose(filename, output, excludes)
    end

    def compose_all_files_in_directory(dirname, path_out, excludes = [])
      Find.find(dirname) do |filename|
        compose(filename, path_out, excludes)
      end
    end
    
    def compose(filename, path_out, excludes = [])
      return unless filename =~ /([\w]+)\.json/
      matched = $1
      return unless excludes.find {|pattern| matched.match(Regexp.compile(pattern)) }.nil?
      
      obj = JsonUtility::json_to_proper_object(load_json(filename), RPG::RootObject(matched)::hash_key_converter)
      save_rvdata2(obj, "#{path_out}/#{matched}.rvdata2")
    end

  end
end

