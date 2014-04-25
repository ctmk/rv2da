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
      ->(obj) { obj.is_a?(Hash) && obj.has_key?(RGSS3_CLASS) }
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
    
    # JsonObjectに変換可能なobjを渡した場合は元のRubyオブジェクトを生成して返し,
    # そうでなければobjをそのまま返す.
    # @return [Object]
    # @param [Hash, Object] obj
    def proper_object(obj)
      case obj
      when json_object?
        json_object_to_proper_object(obj)
      else
        obj
      end
    end
    
    # JSONから読み取ったオブジェクトを、可能なものは元のRubyオブジェクトに変換して返す
    # @param [Object] obj
    # @return [Object]
    def json_to_proper_object(obj)
      case obj
      when json_object?
        json_object_to_proper_object(obj)
      when Hash
        Hash[
          obj.keys.zip(obj.values.collect {|item| proper_object(item)})
        ]
      when Array
        obj.collect do|item|
          proper_object(item)
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
    if args[0].is_a?(JsonObject)
      from_json(args[0])
    else
      initialize_org_json_utility(*args)
    end
  end
  
  # JsonObjectを使って初期化する
  # @param [JsonObject] obj
  def from_json(obj)
    obj.each do|key, value|
      instance_variable_set_converting_hash_key(key, JsonUtility::json_to_proper_object(value))
    end
  end
  
  # Hashのキーを型変換しなければいけないものと変換方法
  # @param [String] Hashの変数名
  # @return [Symbol] 変換方法(メソッド名) if 変換する場合
  # @return [NilClass] if 変換しない場合
  def hash_key_converter(name)
    nil
  end

  # Hashのキーを型変換して値を設定する
  def instance_variable_set_converting_hash_key(name, value)
    conv = value.is_a?(Hash) && hash_key_converter(name)
    if conv
      instance_variable_set(name, Hash[value.keys.collect {|item| item.send(conv) }.zip(value.values)])
    else
      instance_variable_set(name, value)
    end
  end

  # Json形式に変換する
  def to_json(*args)
    { RGSS3_CLASS => self.class.to_s }.merge(Hash[
      instance_variables.collect {|name|
        [name, instance_variable_get(name)]
      }
    ]).to_json(*args)
  end
  
  # @return [Boolean] 同値チェックに成功するか
  def ==(obj)
    instance_variables.find do|key|
      instance_variable_get(key) != obj.instance_variable_get(key)
    end.nil?
  end
  
end
