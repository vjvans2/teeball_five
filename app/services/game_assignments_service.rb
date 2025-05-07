class GameAssignmentsService
  include PlayersAvailable
  include GameAssignmentGenerator
  include Assignable
  include Saveable
  include Loggable

  attr_reader :gameday_team, :game_id, :number_of_gameday_players, :number_of_innings, :override_log, :override_counter
  def initialize(gameday_team, num_innings = 6)
    @gameday_team = gameday_team
    @game_id = @gameday_team.game_id
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @override_log = []
    @override_counter = 0
  end

  def generate_game_assignments
    initialized = initial_assignments(@gameday_team, @number_of_gameday_players, @number_of_innings)
    assignments = generate_player_game_assignments(initialized, @number_of_innings, @override_log, @override_counter)

    write_overrides_to_log(@override_counter, @override_log)

    save_player_inning_assignments(assignments, @gameday_team.game_id, @number_of_innings)
    save_player_counters(assignments)

    assignments
  end

  def retrieve_prior_game_assignments
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
            player_inning_id: inning.id,
            inning_number: inning.inning.inning_number,
            position: inning.fielding_position&.name.nil? ? "------" : inning.fielding_position.name
          }
        end
      }
    end.sort_by { |x| x[:batting_order] }
  end

  def current_game_inning_ids
    game_inning_positions = []
    (1..@number_of_innings).each do |num|
      inning_ids = flat_player_innings.select { |fpi| fpi.inning.inning_number == num }.map(&:fielding_position_id).compact.sort
      positions_missing_ids = expected_game_inning_ids.tally.flat_map { |k, v| [ k ] * (v - inning_ids.tally[k].to_i) if v > inning_ids.tally[k].to_i }.compact

      game_inning_positions << {
        inning_num: num,
        inning_valid?: positions_missing_ids.empty?,
        positions_missing: FieldingPosition.find(positions_missing_ids).map(&:name)
      }
    end
    game_inning_positions
  end

  private

  def flat_player_innings
    @flat_player_innings ||= @gameday_team.gameday_players.sort_by { |player| player[:jersey_number] }.map do |gameday_player|
      gameday_player.player_innings.select { |gdpi| gdpi[:game_id] == game_id }
    end.flatten
  end

  def expected_game_inning_ids
    nill_id = FieldingPosition.find_by_name("NILL").id
    of_id = FieldingPosition.find_by_name("OF").id

    base_positions = %w[P C 1B 2B SS 3B]
    base_ids = FieldingPosition.where(name: base_positions).map(&:id)

    final = []
    final << base_ids
    case @number_of_gameday_players
    when 8
      final << Array.new(2) { of_id }
    when 9
      final << Array.new(3) { of_id }
    when 10
      final << Array.new(4) { of_id }
    when 11
      final << Array.new(4) { of_id }
      final << Array.new(1) { nill_id }
    when 12
      final << Array.new(4) { of_id }
      final << Array.new(2) { nill_id }
    when 13
      final << Array.new(4) { of_id }
      final << Array.new(3) { nill_id }
    else
      "hi mom"
    end
    final.flatten.sort
  end
end
