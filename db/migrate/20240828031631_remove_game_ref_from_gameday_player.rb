class RemoveGameRefFromGamedayPlayer < ActiveRecord::Migration[7.2]
  def change
    remove_column :gameday_players, :game_id, :bigint
  end
end
