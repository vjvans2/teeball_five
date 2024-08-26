class FieldingPosition < ApplicationRecord
  belongs_to :player_inning, optional: true
end
