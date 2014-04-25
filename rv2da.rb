#! ruby -Ku
# coding: utf-8

=begin
データ系の.rvdata2ファイルとJSONファイルの相互変換を行う
Author: Nobu
=end

Version = "1.1.0"

require_relative "./Rv2DataAssembler"
require "optparse"

Options = Struct.new("Options", :mode, :input, :output, :exclude, )

# コマンドラインパラメータを読み込む
# @return [Options]
def parse_arguments
  options = Options.new(nil)
  
  optparser = OptionParser.new
  
  optparser.on("-c", "--compose FILE", "Compose: specify a source file or directory path") do|val|
    options.input = val
    options.mode = :compose
  end
  
  optparser.on("-d", "--decompose FILE", "Decompose: specify a source file or directory path") do|val|
    options.input = val
    options.mode = :decompose
  end
  
  optparser.on("-o", "--output DIR", "destination directory") do|val|
    options.output = val
  end
  
  optparser.on("-e", "--excludes FILE", "exclude file") do|val|
    options.exclude = val
  end
  
  # parse and validate
  begin
    optparser.parse(ARGV)

    case options.mode
    when :compose, :decompose
    else
      STDERR.puts "Error!! specify -c or -d"
      raise
    end
    
    unless options.output && File.directory?(options.output)
      STDERR.puts "Error!! #{options.output} is not found or is not directory"
      raise
    end
    
    unless options.input && File.exist?(options.input)
      STDERR.puts "Error!! #{options.input} is not found"
      raise
    end
    
    if options.exclude && File.exist?(options.exclude).!
      STDERR.puts "Error!! #{options.exclude} is not file"
      raise
    end

  rescue
    # show usage
    optparser.parse("--help")
  end
  
  options
end

# Entry point
def main
  options = parse_arguments

  # [Module]
  mod =
    case options.mode
    when :compose
      Composition
    when :decompose
      Decomposition
    end

  # [Array<String>]
  excludes =
    options.exclude &&
    open(options.exclude) {|f|
      f.readlines.collect {|line| line.chomp }
    } || []

  # [Symbol]
  action = File.directory?(options.input) ? :do_all : :do

  # compose / decompose
  mod.send(action, options.input, options.output, excludes)  if mod
end
main
