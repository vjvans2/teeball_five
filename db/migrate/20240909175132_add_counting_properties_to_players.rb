class AddCountingPropertiesToPlayers < ActiveRecord::Migration[7.2]
  def change
    add_column :players, :leadoffs, :bigint
    add_column :players, :homeruns, :bigint
    add_column :players, :postgame_cheer, :bigint
    add_column :players, :direct_out, :bigint
    add_column :players, :assist_out, :bigint
  end
end
