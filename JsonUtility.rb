=begin
RGSS3で定義されたクラスをJSONファイルとして読み書きするためのモジュール
Author: Nobu
=end

module JsonUtility
  # JSONに出力されたオブジェクトを表現するラッパークラス
  class JsonObject < Hash; end

  # 型情報を残すためのキー
  RGSS3_CLASS = "rgss3_klass"

  # JsonObjectとの変換に関する機能
  class << self
    # JSONのデータをJsonObjectに変換する
    # @return [JsonObject]
    # @param [Hash, nil] Jsonから読み取ったJsonObjectに変換可能なハッシュデータ
    # @note 変換可能かのチェックは呼び出し側で行うこと
    def json_object(obj)
      JsonObject.new.replace(obj || {}).keep_if {|k, v| k != RGSS3_CLASS }
    end
    
    # @return [Proc] JsonObjectに変換可能かをチェックするProc
    def json_object?
      ->(obj) { obj.has_key?(RGSS3_CLASS) rescue false }
    end
    
    # return [String] JsonObjectから元に戻す対象のクラス名
    # @param [JsonObject] obj
    def proper_class_name(obj)
      obj[RGSS3_CLASS]
    end
    
    # JsonObjectから元に戻すクラスを取得する
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
    
    # @return [Object] objから元のRubyオブジェクトを生成して返す
    # @param [Hash] obj
    # @note 変換可能かのチェックは呼び出し側で行うこと
    def json_object_to_proper_object(obj)
      proper_class(obj).new(json_object(obj))
    end
    
    # JSONから読み取ったオブジェクトを、可能なものは元のRubyオブジェクトに変換して返す
    # @param [Object] obj
    # @param [Proc] hash_converted
    # @return [Object]
    def json_to_proper_object(obj, hash_converter = nil, nest_level = 0)
      case obj
      when json_object?
        json_object_to_proper_object(obj)
      when Hash
        key = hash_converter.call(nest_level, obj.keys) rescue obj.keys
        Hash[
          key.zip(obj.values.collect {|item| json_to_proper_object(item, hash_converter, nest_level+1)})
        ]
      when Array
        obj.collect do|item|
          json_to_proper_object(item, hash_converter, nest_level+1)
        end
      else
        obj
      end
    end
    
  end
end

module JsonUtility

  # 一番目の引数にJsonObjectが指定されていればJsonObjectを使って初期化し,
  # そうでなければ通常のコンストラクタを呼び出す.
  # @note alias initialize_org_json_utility initialize してから呼び出す
  def initialize_from_json_object(*args)
    case args[0]
    when JsonObject
      from_json(args[0])
    else
      initialize_org_json_utility(*args)
    end
  end
  
  # JsonObjectを使って初期化する
  # @param [Object] self
  def from_json(obj)
    obj.each do|key, value|
      instance_variable_set(key, JsonUtility::json_to_proper_object(value, hash_key_converter(key)))
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
