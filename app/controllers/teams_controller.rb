class TeamsController < ApplicationController
  before_action :_set_team, only: [ :show, :edit, :update, :destroy ]

  # GET /teams
  def index
    # this is not sustainable for very long. Will eventually need to paginate
    # but this will work for now as we develop.
    @teams = Team.all
  end

  # GET /teams/:id
  def show
    p "hello from show"
    # TeamsService.new(params[:id]).generate_team_report
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # POST /teams
  def create
    @team = Team.new(_team_params)
    if @team.save
      redirect_to @team, notice: "Team was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /teams/:id/edit
  def edit; end

  # PATCH/PUT /teams/:id
  def update
    if @team.update(_team_params)
      redirect_to @team, notice: "Team was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /teams/:id
  def destroy
    if @team.destroy
      Rails.logger.info("Team #{@team.id} was successfully deleted")
      redirect_to teams_url, notice: "Team was successfully deleted."
    else
      Rails.logger.error("Failed to delete team #{@team.id}")
      redirect_to teams_url, alert: "Team could not be deleted."
    end
  end

  private

  def _set_team
    @team = Team.find(params[:id])
  end

  def _team_params
    params.require(:team).permit(:city, :name)
  end
end
