# this isn't in play yet, but it could/should be.
module CreationHelper
  def create_fielding_positions
    positions = %w[P C 1B 2B SS 3B NILL OF]
    positions.each do |position|
      rank = case position
      when 'P', '1B' then 1
      when '2B', 'SS', '3B' then 2
      when 'NILL' then 4
      when 'OF' then 5
      else 3
      end
      create(:fielding_position, name: position, hierarchy_rank: rank)
    end
  end

  def create_gameday_team_with_players(number_of_gameday_players, number_of_innings, with_previous_assignments)
    team = create(:team)
    game = create(:game)
    gameday_team = create(:gameday_team, team: team, game: game)

    players = create_list(:player, number_of_gameday_players, team: team)
    players.map { |player| create(:gameday_player, player: player, gameday_team: gameday_team) }

    return unless with_previous_assignments

    innings = create_list(:inning, number_of_innings, game: game)
    players.each do |player|
      innings.each do |inning|
        create(:player_inning, inning: inning, player: player, fielding_position: FieldingPosition.all.sample, game: game)
      end
    end
  end
end
