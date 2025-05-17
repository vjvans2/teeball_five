class PlayerInningsController < ApplicationController
  def edit
    @gameday_team = GamedayTeam.find(params[:gameday_team_id])
    @player_innings = @gameday_team.game.game_assignments
    @invalid_innings = @gameday_team.game.current_game_inning_ids.select { |cgii| cgii[:inning_valid?] == false }
  end

  def update_multiple
    # add validation here to make sure that no nil remain in the params and that a final
    # inning check would pass

    params[:player_innings].each do |id, pi_params|
      player_inning = PlayerInning.find(id)
      player_inning.update(
        fielding_position_id:  FieldingPosition.find_by_name(pi_params[:position]).id
      )
    end
    redirect_to game_path(params[:game_id]), notice: "Assignments updated"
  end
end
