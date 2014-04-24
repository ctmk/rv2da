module RPG; end
module RGSS3; module RPG; end; end

require "./rpg/Table"
require "./rpg/Tone"
require "./rpg/Color"
require "./rpg/rpg_actor"
require "./rpg/rpg_animation"
require "./rpg/rpg_animation_frame"
require "./rpg/rpg_animation_timing"
require "./rpg/rpg_armor"
require "./rpg/rpg_audiofile"
require "./rpg/rpg_baseitem"
require "./rpg/rpg_baseitem_feature"
require "./rpg/rpg_bgm"
require "./rpg/rpg_bgs"
require "./rpg/rpg_class"
require "./rpg/rpg_class_learning"
require "./rpg/rpg_commonevent"
require "./rpg/rpg_enemy"
require "./rpg/rpg_enemy_action"
require "./rpg/rpg_enemy_drop_item"
require "./rpg/rpg_equipitem"
require "./rpg/rpg_event"
require "./rpg/rpg_event_page"
require "./rpg/rpg_event_page_condition"
require "./rpg/rpg_event_page_graphic"
require "./rpg/rpg_eventcommand"
require "./rpg/rpg_item"
require "./rpg/rpg_map"
require "./rpg/rpg_map_encounter"
require "./rpg/rpg_mapinfo"
require "./rpg/rpg_me"
require "./rpg/rpg_movecommand"
require "./rpg/rpg_moveroute"
require "./rpg/rpg_se"
require "./rpg/rpg_skill"
require "./rpg/rpg_state"
require "./rpg/rpg_system"
require "./rpg/rpg_system_terms"
require "./rpg/rpg_system_testbattler"
require "./rpg/rpg_system_vehicle"
require "./rpg/rpg_tileset"
require "./rpg/rpg_troop"
require "./rpg/rpg_troop_member"
require "./rpg/rpg_troop_page"
require "./rpg/rpg_troop_page_condition"
require "./rpg/rpg_usableitem"
require "./rpg/rpg_usableitem_damage"
require "./rpg/rpg_usableitem_effect"
require "./rpg/rpg_weapon"

class RPG::Map
  def hash_key_converter(name)
    case name.intern
    when :@events
      :to_i
    end
  end
end
