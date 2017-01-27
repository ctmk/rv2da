#! ruby -Ku
# coding: utf-8

=begin
  データ系の.rvdata2ファイルとJSONファイルの相互変換を行う.
=end

Version = "1.2.2"

require_relative "./rv2da_converter"
require "optparse"

module Rv2da
  Options = Struct.new("Options", :mode, :input, :output, :exclude, )
  class InvalidArgument < StandardError; end

  # @parma [Array] argv
  def self.run(argv, stdout = $stdout)
    options = parse_arguments(argv)
  
    # [Class]
    converter =
      case options.mode
      when :compose
        Converter::Composition
      when :decompose
        Converter::Decomposition
      end
  
    # [Array<String>]
    excludes =
      options.exclude &&
      open(options.exclude) {|f|
        f.readlines.collect {|line| line.chomp }
      } || []
  
    # convert
    if File.directory?(options.input)
      converter.convert_all(options.input, options.output, excludes)
  
    elsif obj = converter.convert(options.input)
      unless options.output
        stdout.write obj
      else
        case
        when File.file?(options.output)
          converter.save(options.output, obj)
        when File.directory?(options.output)
          name = File.basename(options.input, ".*")
          converter.save("#{options.output}/#{name}#{converter.extension}", obj)
        end
      end
    end
  end

  # @return [Options]
  # @parma [Array] argv
  def self.parse_arguments(argv)
    options = Options.new(nil)
    optparser = OptionParser.new

    def optparser.error(msg = nil)
      warn msg if msg
      warn help()
      raise InvalidArgument
    end
    
    define_options(optparser, options)
    
    begin
      optparser.parse(argv)
    rescue OptionParser::ParseError => err
      optparser.error err.message
    end

    validate_options(optparser, options)

    options
  end
  
  def self.define_options(optparser, options)
    optparser.on("-c", "--compose=FILE", "Compose: specify a source file or directory path") do|val|
      options.input = val
      options.mode = :compose
    end
    
    optparser.on("-d", "--decompose=FILE", "Decompose: specify a source file or directory path") do|val|
      options.input = val
      options.mode = :decompose
    end
    
    optparser.on("-o", "--output=DIR|FILE", "destination file or directory") do|val|
      options.output = val
    end
    
    optparser.on("-e", "--excludes=FILE", "exclude list") do|val|
      options.exclude = val
    end
  end
  
  def self.validate_options(optparser, options)
    case options.mode
    when :compose, :decompose
    else
      optparser.error "specify -c or -d"
    end
    
    unless options.input && File.exist?(options.input)
      optparser.error %Q("#{options.input}" is not found)
    end
    
    if File.directory?(options.input) && (!options.output ||  !File.directory?(options.output))
      optparser.error %Q("#{options.output}" is not a directory, but input is a directory)
    end
    
    if options.exclude && not(File.file?(options.exclude))
      optparser.error %Q("#{options.exclude}" is not a file)
    end
  end
  

end

begin
  Rv2da.run(ARGV)
rescue Rv2da::InvalidArgument
  # The command-line arguments are invalid
  exit 1
rescue Rv2da::Converter::InvalidFormatedFile => err
  # Failed to convert because the source file is invalid format
  warn err.message
  exit 1
end
