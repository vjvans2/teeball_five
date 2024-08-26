class ChangeFieldingPositionIdOnPlayerInningToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :player_innings, :fielding_position_id, true
  end
end
