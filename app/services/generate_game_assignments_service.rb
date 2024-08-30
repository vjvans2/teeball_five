class GenerateGameAssignmentsService
  attr_reader :gameday_team, :iterable_players_size, :number_of_innings, :positions

  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @iterable_players_size = gameday_team.gameday_players.size
    @number_of_innings = num_innings

    # if gameday_team.gameday_players.count > positions, add nils to get to the match
    @positions = FieldingPosition.all.map(&:name)
  end

  def generate_game_assignments
    # Initialize previous assignments and outfield counts
    previous_assignments = Array.new(@iterable_players_size) { Set.new }
    # outfield_counts = Array.new(@iterable_players_size) { Hash.new(0) }

    # creates template/grid
    initial_assignments = Array.new(@number_of_innings) { Array.new(@iterable_players_size) }

    schedule = generate_assignments(0, initial_assignments, previous_assignments)

    p schedule
  end

  private
  # Helper method to validate the current assignments
  def valid_assignment?(assignments, previous_assignments)
    # # Ensure no player is assigned the same position twice
    # (0...@iterable_players_size).each do |i|
    #   if previous_assignments[i].include?(assignments[i])
    #     return false
    #   end
    # end

    # # Ensure P is not also 1B
    # if assignments.include?("P") && assignments.include?("1B")
    #   p_index = assignments.index("P")
    #   b_index = assignments.index("1B")
    #   return false if p_index && b_index && p_index == b_index
    # end

    # # Ensure each player plays exactly two outfield positions, if applicable
    # (0...@iterable_players_size).each do |i|
    #   if assignments[i] == "P" || assignments[i] == "1B"
    #     next
    #   else
    #     outfield_count = outfield_counts[i].values.sum
    #     return false unless outfield_count == 2
    #   end
    # end

    true
  end

  # Recursive function to generate assignments
  def generate_assignments(inning_index, initial_assignments, previous_assignments)
    if inning_index == @number_of_innings
      return initial_assignments
    end

    # outfield_positions = %w[LF LC RC RF]
    @positions.shuffle.each do |pos|
      new_assignments = initial_assignments.dup
      new_assignments[inning_index-1] = pos

      # # Update outfield counts
      # new_outfield_counts = outfield_counts.map(&:dup)
      # (0...@iterable_players_size - 1).each do |i|
      #   if outfield_positions.include?(pos)
      #     new_outfield_counts[i][pos] += 1
      #   end
      # end

      p "hi from generate_assignments::inning_index ---- #{inning_index}"
      # p "hi from generate_assignments::previous_assignments ---- #{previous_assignments}"
      # p "hi from generate_assignments::new_outfield_counts ---- #{new_outfield_counts}"

      valid = valid_assignment?(new_assignments[inning_index-1], previous_assignments)

      p "position and valid ------ pos: #{pos}, valid: #{valid}"

      if valid
        # Update previous assignments
        updated_previous_assignments = previous_assignments.map(&:dup)
        (0...@iterable_players_size).each do |i|
          updated_previous_assignments[i] << new_assignments[inning_index-1][i]
        end

        result = generate_assignments(inning_index + 1, new_assignments, updated_previous_assignments)
        return result if result
      end
    end

    nil
  end
end
