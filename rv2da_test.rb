#! ruby -Ku
# coding: utf-8

=begin
  rv2daのテストを実行する
=end

require "test/unit"
require "fileutils"
require "find"

$VERBOSE = nil
begin
  require_relative "./rv2da"
rescue SystemExit
end

class Rv2da::Test < Test::Unit::TestCase
  NULL = Object.new
  def NULL.write(s); s.length; end
  
  def setup
  end
  
  def teardown
  end
  
  def test_argv
    # No options
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run([]) }
    
    # Missing specifying a file
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-c']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-d']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-e']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-o']) }

    # Specified a directory but output is not specified
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-d', 'testdata']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-c', 'testdata']) }

    # Specified a directory but output does not exist
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-d', 'testdata', '-o', 'none']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-c', 'testdata', '-o', 'none']) }
    
    # Specified a file which does not exist
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-d', 'testdata/none.rvdata2']) }
    assert_raise(Rv2da::InvalidArgument) { Rv2da.run(['-c', 'testdata/none.json']) }
    
    # Specified a file and itended to output to stdout
    assert_nothing_raised() { Rv2da.run(['-d', 'testdata/sample/Actors.rvdata2'], NULL) }
    assert_nothing_raised() { Rv2da.run(['-c', 'testdata/sample/Actors.json'], NULL) }

    # Specified a file and itended to output to a directory
    assert_nothing_raised() { Rv2da.run(['-d', 'testdata/sample/Actors.rvdata2', '-o', 'testdata/output']) }
    assert_nothing_raised() { Rv2da.run(['-c', 'testdata/sample/Actors.json', '-o', 'testdata/output']) }
  end
  
  def test_equality_check
    actors1 = File.open('testdata/sample/Actors.rvdata2', 'rb') {|f| Marshal.load(f) }
    actors2 = File.open('testdata/sample/Actors.rvdata2', 'rb') {|f| Marshal.load(f) }
    assert(actors1 == actors2)
    
    # Not equal if some instance variables are not equal
    actors1[1].name += "hoge"
    assert(actors1 != actors2)

    actors1 = File.open('testdata/sample/Actors.rvdata2', 'rb') {|f| Marshal.load(f) }
    assert(actors1 == actors2)
    
    # Not equal if some instance variables are found on only one side
    actors1[1].instance_variable_set(:@hoge, 'hoge')
    assert(actors1 != actors2)
  end
  
  def test_converting_file
    FileUtils.remove_dir('testdata/output')
    FileUtils.mkdir('testdata/output')

    Rv2da.run(['-d', 'testdata/sample/Actors.rvdata2', '-o', 'testdata/output'])
    assert(File.exist?('testdata/output/Actors.json'))

    Rv2da.run(['-c', 'testdata/output/Actors.json', '-o', 'testdata/output'])
    assert(File.exist?('testdata/output/Actors.rvdata2'))
    
    original = File.open('testdata/sample/Actors.rvdata2', 'rb') {|f| Marshal.load(f) }
    converted = File.open('testdata/output/Actors.rvdata2', 'rb') {|f| Marshal.load(f) }
    assert(original == converted)
  end
  
  def test_converting_directory
    FileUtils.remove_dir('testdata/output')
    FileUtils.mkdir('testdata/output')

    Rv2da.run(['-d', 'testdata/sample/', '-o', 'testdata/output'])
    Find.find('testdata/sample') do|filename|
      next unless File.file?(filename)
      next if /^\./ === (name = File.basename(filename, ".*"))

      assert(File.exist?("testdata/output/#{name}.json"), "#{filename} - #{name}")
    end

    Rv2da.run(['-c', 'testdata/output/', '-o', 'testdata/output'])
    Find.find('testdata/sample') do|filename|
      next unless File.file?(filename)
      next if /^\./ === (name = File.basename(filename, ".*"))

      original = File.open("testdata/sample/#{name}.rvdata2", 'rb') {|f| Marshal.load(f) }
      converted = File.open("testdata/output/#{name}.rvdata2", 'rb') {|f| Marshal.load(f) }
      assert(original == converted, "#{filename} - #{name}")
    end
  end
  
  def test_converting_directory_with_exclude_list
    FileUtils.remove_dir('testdata/output')
    FileUtils.mkdir('testdata/output')

    Rv2da.run(['-d', 'testdata/sample/', '-o', 'testdata/output', '-e', 'testdata/excludes'])
    assert(! File.exist?('testdata/output/Actors.rvdata2'))
  end
  
  def test_converting_invalid_files
    assert_raise(Rv2da::Converter::InvalidFormatedFile) {
      Rv2da.run(['-d', 'testdata/excludes', '-o', 'testdata/test.json'])
    }

    assert_raise(Rv2da::Converter::InvalidFormatedFile) {
      Rv2da.run(['-c', 'testdata/excludes', '-o', 'testdata/test.rvdata2'])
    }
  end
  
end
