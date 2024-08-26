class AddIsHeadCoachToCoach < ActiveRecord::Migration[7.2]
  def change
    add_column :coaches, :is_head_coach, :boolean
  end
end
