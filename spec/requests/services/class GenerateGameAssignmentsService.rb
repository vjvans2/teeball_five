class GenerateGameAssignmentsService
  attr_reader :gameday_team, :iterable_players_size, :number_of_innings, :positions

  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @iterable_players_size = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @positions = FieldingPosition.all.map(&:name)
  end

  def generate_game_assignments
    previous_assignments = Array.new(@iterable_players_size) { Set.new }
    initial_assignments = Array.new(@number_of_innings) { Array.new(@iterable_players_size) }
    schedule = generate_assignments(0, initial_assignments, previous_assignments)

    p schedule
  end

  private
  def valid_assignment?(new_assignments, previous_assignments)
    # Check for position repetition
    current_assignments_by_player = previous_assignments.map(&:dup)

    new_assignments.each_with_index do |position, player_index|
      if current_assignments_by_player[player_index].include?(position)
        return false
      end
    end

    true
  end

  # Recursive function to generate assignments
  def generate_assignments(inning_index, initial_assignments, previous_assignments)
    if inning_index == @number_of_innings
      return initial_assignments
    end

    @positions.shuffle.each do |pos|
      new_assignments = initial_assignments.dup
      new_assignments[inning_index] = pos

      valid = valid_assignment?(new_assignments, previous_assignments)

      if valid
        updated_previous_assignments = previous_assignments.map(&:dup)
        (0...@iterable_players_size).each do |i|
          updated_previous_assignments[i] << new_assignments[inning_index][i]
        end

        result = generate_assignments(inning_index + 1, new_assignments, updated_previous_assignments)
        return result if result
      end
    end

    nil
  end
end
