class SetPlayerCountersToNotNullAndZeroDefault < ActiveRecord::Migration[7.2]
  def change
    player_counter_property_symbols = [ :assist_out, :direct_out, :homeruns, :leadoffs, :postgame_cheer, :sat_out ]

    player_counter_property_symbols.each do |prop|
      change_column_default :players, prop, 0
      change_column_null :players, prop, false
    end
  end
end
