class AddInningsSatOutCounterPropertyToPlayers < ActiveRecord::Migration[7.2]
  def change
    add_column :players, :sat_out, :bigint
  end
end
