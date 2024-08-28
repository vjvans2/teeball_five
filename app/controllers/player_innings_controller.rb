class PlayerInningsController < ApplicationController
  def post
    PlayerInningsService.new(params)
  end
end
