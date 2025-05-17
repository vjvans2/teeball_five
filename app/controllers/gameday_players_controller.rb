class GamedayPlayersController < ApplicationController
  def new
    @gameday_team_id = params[:gameday_team_id]
    @players = gameday_team.team.players.map { |p| { id: p.id, label_name: p.gameday_player_label_name, jersey_number: p.jersey_number } }.sort_by { |pl| pl[:jersey_number] }
    render status: :ok
  end

  def show
    render status: :ok
  end

  def create
    checked_players = params[:gameday_players].map { |p| p[:player_id] }
    gameday_team_id = params[:gameday_team_id].to_i

    checked_players.each do |player_id|
      GamedayPlayer.create!(
        player_id:,
        is_present: true,
        gameday_team_id:
      )
    end

    # TODO: add a spot to put in the num of innings
    GameAssignmentsService.new(gameday_team, 6).generate_game_assignments

    redirect_to edit_game_player_innings_path(gameday_team_id: gameday_team_id), notice: "Game successfully created"
  end

  private

  def gameday_team
    @gameday_team ||= GamedayTeam.find_by(id: params[:gameday_team_id])
  end
end
