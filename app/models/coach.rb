class Coach < ApplicationRecord
  belongs_to :team
  belongs_to :player, optional: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
