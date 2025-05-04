module Saveable
  def save_player_inning_assignments(player_game_assignments, game_id, number_of_innings)
    (1..number_of_innings).each do |inning_number|
    p "------- INNING #{inning_number} ------- "
      inning = Inning.find_or_create_by!(game_id: game_id, inning_number: inning_number)
      player_game_assignments.each_with_index do |player, batting_order_index|
     inning_fielding_position_id = FieldingPosition.find_by_name(player[:game_assignments][inning_number - 1])&.id
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

  def save_player_counters(player_game_assignments)
    # save the leadoffs, homeruns preset from the assignments here

    # grab the players from {gameday_team.team_size_leadoff_homerun_chart} and pluck their player_ids
    # to increment leadoffs and homeruns
    # since 10 players mvp/default

    # THIS NEEDS TO BE BEHIND A TEEBALL FLAG VS. COACH PITCH AND GREATER
    leadoffs = player_game_assignments.first(4).map { |leadoff| leadoff[:player_id] }
    homeruns = player_game_assignments.first(3).map { |hr| hr[:player_id] }
    homeruns << player_game_assignments.last[:player_id]

    leadoffs.each do |leadoff_player_id|
      Player.find(leadoff_player_id).increment!(:leadoffs)
    end

    homeruns.each do |homerun_player_id|
      Player.find(homerun_player_id).increment!(:homeruns)
    end

    #
    # Need to increment sit_outs for those that apply for >10
    #
  end
end
