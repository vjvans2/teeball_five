class TeamsController < ApplicationController
  def index
    # this is not sustainable for very long. Will eventually need to paginate
    # but this will work for now as we develop.
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
  end
end
