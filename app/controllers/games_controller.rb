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
