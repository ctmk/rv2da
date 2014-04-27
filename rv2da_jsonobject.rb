=begin
  RGSS3で定義されたクラスをJSONファイルとして読み書きする
=end

module Rv2da
  module JsonObject
    # JSONのObjectに型情報を残すためのキー
    RGSS3_CLASS = "rgss3_klass"

    # JSONに出力されたRGSS3のオブジェクトを表現するラッパークラス
    class Rgss3Object < Hash
      def to_proper_object(hash_converter = nil, nest_level = 0)
        Rv2da::JsonObject.proper_class(self).new(self.delete_if {|k, v| k == RGSS3_CLASS })
      end
    end

    # JsonObjectとの変換に関する機能
    class << self

      # @return [Rgss3Object] if 変換可能であれば
      # @return [Object] if 変換可能でなければ
      # @param [Object] obj 任意のオブジェクト
      def json_object(obj)
        return obj unless json_object? === obj
        Rgss3Object.new.replace(obj)
      end
      
      # @return [Proc] Rgss3Objectに変換可能かをチェックするProc
      def json_object?
        ->(obj) { obj.has_key?(RGSS3_CLASS) rescue false }
      end
      
      # return [String] 元に戻すクラス名
      # @param [Hash] obj
      def proper_class_name(obj)
        obj[RGSS3_CLASS]
      end
      
      # Rgss3Objectから元に戻すクラスを取得する
      # @return [Class] objの元々のRubyクラス
      # @param [Hash] obj
      def proper_class(obj)
        nested_const_get(proper_class_name(obj))
      end
  
      # ネストした定数を取得する
      # @return [Object]
      def nested_const_get(fullname)
        fullname.split(/::/).inject(Object) {|obj, name| obj.const_get(name) }
      end
      
      # JSONから読み取ったオブジェクトを、可能なものは元のRubyオブジェクトに変換して返す
      # @param [Object] obj
      # @param [Proc] hash_converted
      # @return [Object]
      def json_to_proper_object(obj, hash_converter = nil, nest_level = 0)
        json_object(obj).to_proper_object(hash_converter, nest_level)
      end

    end
  end
end

module Rv2da::JsonObject

  # 一番目の引数にRgss3Objectが指定されていればRgss3Objectを使って初期化し,
  # そうでなければ通常のコンストラクタを呼び出す.
  def initialize(*args)
    case args[0]
    when Rgss3Object
      from_json(args[0])
    else
      super(*args)
    end
  end
  
  # Rgss3Objectを使って初期化する
  # @param [Object] self
  def from_json(obj)
    obj.each do|key, value|
      instance_variable_set(key, Rv2da::JsonObject.json_to_proper_object(value, hash_key_converter(key)))
    end
    self
  end
  
  # Hashのキーを型変換しなければいけないものと変換方法
  # JsonではHashのキーを文字列型でしか持てないので,
  # 文字列以外のキーが必要な場合は、変換方法を実装する.
  # @param [String] name Hashの変数名
  # @return [Proc] nest_level, keysを受け取って変換後のkeysを返すProc
  def hash_key_converter(name)
    ->(nest_level, keys) { keys }
  end

  # Json形式に変換する
  # メンバ変数名/値をkey/valueとしてもつObjectとして扱う
  def to_json(*args)
    { RGSS3_CLASS => self.class.to_s }.merge(Hash[
      instance_variables.collect {|name|
        [name, instance_variable_get(name)]
      }
    ]).to_json(*args)
  end
  
  # 同値チェック
  # @return [Boolean] 全てのインスタンス変数が同じ値か
  def ==(obj)
    instance_variables == obj.instance_variables &&
    instance_variables.all? {|key|
      instance_variable_get(key) == obj.instance_variable_get(key)
    }
  end
  
end

class Object
  def to_proper_object(hash_converter = nil, nest_level = 0)
    self
  end
end

class Array
  def to_proper_object(hash_converter = nil, nest_level = 0)
    collect do|item|
      Rv2da::JsonObject.json_to_proper_object(item, hash_converter, nest_level+1)
    end
  end
end

class Hash
  def to_proper_object(hash_converter = nil, nest_level = 0)
    key = hash_converter.call(nest_level, keys) rescue keys
    Hash[
      key.zip(values.collect {|item| Rv2da::JsonObject.json_to_proper_object(item, hash_converter, nest_level+1)})
    ]
  end
end
