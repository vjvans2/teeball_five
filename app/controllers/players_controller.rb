class PlayersController < ApplicationController
  before_action :_set_team, only: [ :new, :create ]
  before_action :_set_player, only: [ :show, :edit, :update, :destroy ]

  # GET /teams/:team_id/players/new
  def new
    @player = @team.players.new
  end

  # POST /teams/:team_id/players
  def create
    @player = @team.players.new(_player_params)
    if @player.save
      redirect_to @team, notice: "Player was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /players/:id
  def show; end

  # GET /players/:id/edit
  def edit; end

  # PATCH/PUT /players/:id
  def update
    if @player.update(_player_params)
      redirect_to @player.team, notice: "Player was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /players/:id
  def destroy
    team = @player.team
    if @player.destroy
      Rails.logger.info("Player #{@player.id} was successfully deleted")
      redirect_to team, notice: "Player was successfully deleted."
    else
      Rails.logger.error("Failed to delete team #{@team.id}")
      redirect_to team, alert: "Player could not be deleted."
    end
  end

  private

  def _set_team
    @team = Team.find(params[:team_id])
  end

  def _set_player
    @player = Player.find(params[:id])
  end

  def _player_params
    params.require(:player).permit(:first_name, :last_name, :jersey_number)
  end
end
