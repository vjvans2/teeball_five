class ChangeAssociatedPlayerOnCoachToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :coaches, :associated_player_id, true
  end
end
