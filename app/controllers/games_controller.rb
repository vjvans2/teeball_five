class GamesController < ApplicationController
  def index
    # this is not sustainable for very long. Will eventually need to paginate
    # but this will work for now as we develop.
    @games = Game.all
  end
  def show
    @game = Game.find(params[:id])
  end

  def post
  end
end
