class GameAssignmentsService
  include PlayersAvailable
  include GameAssignmentGenerator
  include Assignable
  include Saveable
  include Loggable

  attr_reader :gameday_team, :number_of_gameday_players, :number_of_innings, :override_log, :override_counter
  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @override_log = []
    @override_counter = 0
  end

  def generate_game_assignments
    initialized = initial_assignments(@gameday_team, @number_of_gameday_players, @number_of_innings)
    assignments = generate_player_game_assignments(initialized, @number_of_innings, @override_counter, @override_log)

    write_overrides_to_log(@override_counter, @override_log)

    save_player_inning_assignments(assignments, @gameday_team.game_id, @number_of_innings)
    save_player_counters(assignments)

    assignments
  end

  def retrieve_prior_game_assignments(game_id)
      flat_player_innings = @gameday_team.gameday_players.sort_by { |player| player[:jersey_number] }.map do |gameday_player|
      gameday_player.player_innings.select { |gdpi| gdpi[:game_id] == game_id }
      end.flatten

      flat_player_innings.group_by(&:player_id)
      .map do |player_id, innings|
        {
          player: {
            name:  Player.find(player_id).full_name,
            jersey_number: Player.find(player_id).jersey_number
          },
          batting_order: innings.first.batting_order,
          game_assignments: innings.map do |inning|
            {
              inning_number: inning.inning.inning_number,
              position: inning.fielding_position.name
            }
          end
        }
      end.sort_by { |x| x[:batting_order] }
  end
end
