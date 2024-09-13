class GenerateGameAssignmentsService
  attr_reader :gameday_team, :number_of_gameday_players, :number_of_innings, :iterations
  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @iterations = 0
  end

  def generate_game_assignments
    schedule = generate_assignments(0, initial_assignments)

    p "iterations required ---- #{@iterations}"
    p schedule
  end

  private

  def initial_assignments
    list = Array.new(@number_of_gameday_players)
    empty_innings = Array.new(@number_of_innings) { nil }

    @gameday_team.gameday_players.each_with_index do |gameday_player, index|
      list[index] = { player_id: gameday_player.player_id, game_assignments: empty_innings.dup }
    end

    list
  end

  # Recursive function to generate assignments
  def generate_assignments(inning_index, player_game_assignments)
    if inning_index == @number_of_innings
      return player_game_assignments
    end

    @iterations += 1

    # resets positions back to original
    positions = GetRandomPosition.new(player_game_assignments, inning_index)

    # player_game_assignments is now an array of all gameday_players
    player_game_assignments.each_with_index do |pga, player_index|
      pos = positions.choose_and_remove(pga[:player_id])
      pga[:game_assignments][inning_index] = pos

      if player_index == player_game_assignments.size - 1
        if positions.is_valid_inning?
          p ("hi from valid inning #{inning_index + 1}")
        else
          p ("hi from invalid inning #{inning_index + 1}, resetting...")

          # try again, brute force for now?
          player_game_assignments.each do |a|
            a[:game_assignments][inning_index] = nil
          end
          generate_assignments(inning_index, player_game_assignments)
        end
      end
    end

    save_player_inning_assignments(player_game_assignments, inning_index)

    result = generate_assignments(inning_index + 1, player_game_assignments)
    return result if result

    nil
  end

  def save_player_inning_assignments(player_game_assignments, inning_index)
    game_id = @gameday_team.game_id
    inning = Inning.create!(game_id: game_id, inning_number: inning_index + 1)
    player_game_assignments.each_with_index do |player, batting_order_index|
      inning_fielding_position_id = FieldingPosition.find_by_name(player[:game_assignments][inning_index]).id
      PlayerInning.create!(
        player_id: player[:player_id],
        inning_id: inning.id,
        fielding_position_id: inning_fielding_position_id,
        batting_order: batting_order_index + 1,
        game_id: game_id
      )
    end
  end
end
