module RPG; end
module RGSS3; module RPG; end; end

require_relative "./rpg/table"
require_relative "./rpg/tone"
require_relative "./rpg/color"
require_relative "./rpg/rpg_actor"
require_relative "./rpg/rpg_animation"
require_relative "./rpg/rpg_animation_frame"
require_relative "./rpg/rpg_animation_timing"
require_relative "./rpg/rpg_armor"
require_relative "./rpg/rpg_audiofile"
require_relative "./rpg/rpg_baseitem"
require_relative "./rpg/rpg_baseitem_feature"
require_relative "./rpg/rpg_bgm"
require_relative "./rpg/rpg_bgs"
require_relative "./rpg/rpg_class"
require_relative "./rpg/rpg_class_learning"
require_relative "./rpg/rpg_commonevent"
require_relative "./rpg/rpg_enemy"
require_relative "./rpg/rpg_enemy_action"
require_relative "./rpg/rpg_enemy_drop_item"
require_relative "./rpg/rpg_equipitem"
require_relative "./rpg/rpg_event"
require_relative "./rpg/rpg_event_page"
require_relative "./rpg/rpg_event_page_condition"
require_relative "./rpg/rpg_event_page_graphic"
require_relative "./rpg/rpg_eventcommand"
require_relative "./rpg/rpg_item"
require_relative "./rpg/rpg_map"
require_relative "./rpg/rpg_map_encounter"
require_relative "./rpg/rpg_mapinfo"
require_relative "./rpg/rpg_me"
require_relative "./rpg/rpg_movecommand"
require_relative "./rpg/rpg_moveroute"
require_relative "./rpg/rpg_se"
require_relative "./rpg/rpg_skill"
require_relative "./rpg/rpg_state"
require_relative "./rpg/rpg_system"
require_relative "./rpg/rpg_system_terms"
require_relative "./rpg/rpg_system_testbattler"
require_relative "./rpg/rpg_system_vehicle"
require_relative "./rpg/rpg_tileset"
require_relative "./rpg/rpg_troop"
require_relative "./rpg/rpg_troop_member"
require_relative "./rpg/rpg_troop_page"
require_relative "./rpg/rpg_troop_page_condition"
require_relative "./rpg/rpg_usableitem"
require_relative "./rpg/rpg_usableitem_damage"
require_relative "./rpg/rpg_usableitem_effect"
require_relative "./rpg/rpg_weapon"

class RPG::Map
  def hash_key_converter(name)
    case name.intern
    when :@events
      ->(nest_level, keys) {
        keys.collect {|key| key.to_i }
      }
    else
      super
    end
  end
end

module RPG

  module DefaultRootObject
    def self.hash_key_converter
      nil
    end
  end
  
  module MapInfosRootObject
    def self.hash_key_converter
      ->(nest_level, keys) {
        keys.collect {|key| key.to_i }
      }
    end
  end

  def self.RootObject(root)
    case root
    when "MapInfos"
      MapInfosRootObject
    else
      DefaultRootObject
    end
  end

end
