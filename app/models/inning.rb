# == Schema Information
#
# Table name: innings
#
#  id            :bigint           not null, primary key
#  inning_number :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  game_id       :bigint           not null
#
# Indexes
#
#  index_innings_on_game_id                    (game_id)
#  index_innings_on_game_id_and_inning_number  (game_id,inning_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#
class Inning < ApplicationRecord
  belongs_to :game
end
