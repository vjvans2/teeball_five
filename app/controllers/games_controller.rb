class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def index
    # this is not sustainable for very long. Will eventually need to paginate
    # but this will work for now as we develop.
    @games = Game.all
  end
  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = Game.new(_game_params)
    @game.season_id = 1
    if @game.save
      gameday_team = create_gameday_team(@game.id)
      redirect_to new_gameday_player_path(gameday_team_id: gameday_team[:id]), notice: "Game successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

    # DELETE /games/:id
    def destroy
      @game = Game.find(params[:id])
      @associated_gameday_team_id = GamedayTeam.find_by(game_id: params[:id]).id

      PlayerInning.where(game_id: @game.id).delete_all
      Inning.where(game_id: @game.id).delete_all
      GamedayPlayer.where(gameday_team_id: @associated_gameday_team_id).delete_all
      GamedayTeam.delete(@associated_gameday_team_id)

      if @game.destroy
        Rails.logger.info("Game #{@game.id} was successfully deleted")
        redirect_to games_url, notice: "Game was successfully deleted."
      else
        Rails.logger.error("Failed to delete game #{@game.id}")
        redirect_to games_url, alert: "Game could not be deleted."
      end
    end

  private

  def _game_params
    params.require(:game).permit(:location, :is_home, :opponent_name, :date)
  end

  def create_gameday_team(game_id)
    # needs to be created here instead of going to the GamedayTeamController because we cannot redirect directly to the CREATE action
    GamedayTeam.create!(
      game_id: game_id,
      team_id: params.dig(:game, :team_id).to_i
    )
  end
end
