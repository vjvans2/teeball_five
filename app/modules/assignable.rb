module Assignable
  def initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)
    list = Array.new(number_of_gameday_players)
    empty_innings = Array.new(number_of_innings) { nil }

    GamedayPlayer.shuffle_by_leadoff(gameday_team.gameday_players).each_with_index do |gameday_player, index|
      list[index] = {
        player_id: gameday_player.player_id,
        player_name: gameday_player.player.full_name,
        leadoffs: gameday_player.player.leadoffs,
        homeruns: gameday_player.player.homeruns,
        game_assignments: empty_innings.dup,
        previous_assignments: player_previous_assignments(gameday_player)
      }
    end

    list
  end

  def player_previous_assignments(gameday_player)
    gameday_player.player_innings
      .group_by(&:game_id)
      .map do |game_id, innings|
        {
          game_id: game_id,
          batting_order: innings.first.batting_order,
          game_assignments: innings.map do |inning|
            {
              inning_number: inning.inning.inning_number,
              position: inning.fielding_position.name
            }
          end
        }
      end
  end
end
