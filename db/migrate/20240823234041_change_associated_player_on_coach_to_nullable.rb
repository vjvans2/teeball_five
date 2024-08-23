class ChangeAssociatedPlayerOnCoachToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :coach, :associated_player, true
  end
end
