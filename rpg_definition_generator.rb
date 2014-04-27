#! ruby -Ku
# coding: utf-8

=begin
source/decompiled/rgss/ にある rgss_xxx.html ファイルから rpg/ に .rb を生成する.
Author: Nobu
=end

require "find"
require "nokogiri"

class RpgDefinitionGenerator
  class << self

    # rv2da用のrbファイルをHTMLファイルから抜き出して作成する
    # @param [String] src_file 元となるHTMLのファイルパス
    # @param [String] dst_file 出力するファイルパス
    def generate(src_file, dst_file)
      code = get_source_code(src_file)
      make_rb_file(dst_file, code)
    end
    
    # ヘルプファイルからソースコード部分の文字列を抜き取る
    # @return [String]
    # @param [String] source filename
    def get_source_code(src_file)
      parse_html(File.read(src_file, :encoding => Encoding::CP932))
    end
    
    # HTMLテキストからソースコード部分の文字列を抜き取る
    # @return [String]
    # @param [String] html
    def parse_html(html)
      Nokogiri::HTML.parse(html, nil).xpath("//pre").text.gsub(/\r\n/, "\n")
    end
    
    # @param [String] dst_file 出力するファイル
    # @param [String] code 出力するソースコード
    def make_rb_file(dst_file, code)
      File.write(dst_file, make_rv2da_code(code))
    end
    
    # @return [String] rv2da用の機能を追加したソースコード
    # @param [String] code ヘルプから取得したソースコード
    def make_rv2da_code(code)
      klass = (code.match(/class[\s]+([\w]+(::[\w]+)*)/) || [])[1]
      base = (code.match(/class[\s]+([\w]+(::[\w]+)*)[\s]*<[\s]*([\w]+(::[\w]+)*)/) || [])[3]
      depend = (base && "require_relative \"./#{base.downcase.gsub(/::/, '_')}.rb\"") || ""
<<CODE
require_relative "../rv2da_jsonobject"
#{depend}

module RGSS3
#{code}
end

class #{klass} < RGSS3::#{klass}
  include Rv2da::JsonObject
end
CODE
    end
    
  end
end

Find.find("source/decompiled/rgss") do |filename|
  if filename =~ /gc_rpg_([\w\W]*)\.html/
    RpgDefinitionGenerator::generate(filename, "rpg/rpg_#{$1}.rb")
  end
end
