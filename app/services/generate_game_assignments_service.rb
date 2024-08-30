class GenerateGameAssignmentsService
  attr_reader :gameday_team, :number_of_gameday_players, :number_of_innings
  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
  end

  def generate_game_assignments
    assignments = Array.new(@number_of_innings) { Array.new(@number_of_gameday_players) }
    schedule = generate_assignments(0, assignments)

    p schedule
  end

  private

  # Recursive function to generate assignments
  def generate_assignments(inning_index, assignments)
    if inning_index == @number_of_innings
      return assignments
    end

    # resets positions back to original
    positions = GetRandomPosition.new
    assignments[inning_index].each_with_index do |player, index|
      pos = positions.choose_and_remove
      assignments[inning_index][index] = pos
      # put validity logic here
    end

    result = generate_assignments(inning_index + 1, assignments)
    return result if result

    nil
  end
end
