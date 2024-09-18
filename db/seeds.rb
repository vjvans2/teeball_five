require 'faker'
require 'date'

# # # run with rake db:seed # # #

# create fielding positions
high_tier_positions = %w[P 1B]
mid_tier_positions = %w[C 2B SS 3B]
positions = %w[LF LC RC RF P C 1B 2B SS 3B]

positions.each do |position|
  rank = case position
  when *high_tier_positions
      1
  when *mid_tier_positions
      2
  else
      3
  end

  FieldingPosition.create!(name: position, hierarchy_rank: rank)
end

# create a team
team = Team.create!(
  name: 'Sharks',
  city: 'Westerville'
)

p "team #{team.id} created"

season = Season.create!(team_id: team.id, name: 'Test Season 1')

p "#{season.name} created"

# create ten players
player_ids = []
(1..10).each do |jersey_num|
  new_player = Player.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      jersey_number: jersey_num,
      team: team
    )

  player_ids << new_player.id
end
p "#{player_ids.count} players added"

# create a head and asst coach
# TODO --- add coach limit, only one head coach, coach titles
associated_player_id = player_ids.sample
Coach.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    associated_player_id: associated_player_id,
    is_head_coach: true,
    team: team
  )
Coach.create!(
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  associated_player_id: nil,
  is_head_coach: false,
  team: team
)

p "2 coaches created"

# create a game instance
game = Game.create!(
  location: Faker::TvShows::Archer.location,
  is_home: true,
  opponent_name: "#{Faker::TvShows::Archer.character}'s whining kids",
  date: Date.yesterday,
  season_id: season.id
)

p "game #{game.id} created"

# create gameday team
gameday_team = GamedayTeam.create!(
  game_id: game.id,
  team_id: team.id
)

p "gameday team #{gameday_team.id} created"

# # create gameday players
gameday_players = []
player_ids.each do |player_id|
  gameday_players << GamedayPlayer.create!(
    player_id: player_id,
    is_present: true,
    gameday_team_id: gameday_team.id
  )
end

p "#{gameday_players.count} gameday_players created"

GenerateGameAssignmentsService.new(gameday_team).generate_game_assignments

p "----- GAME 1 PLAYERINNINGS CREATED -----"

# create a game instance
game_two = Game.create!(
  location: Faker::TvShows::Archer.location,
  is_home: true,
  opponent_name: "#{Faker::TvShows::Archer.character}'s whining kids",
  date: Date.today,
  season_id: season.id
)

p "game #{game.id} created"

# create gameday team
gameday_team_two = GamedayTeam.create!(
  game_id: game_two.id,
  team_id: team.id
)

p "gameday team #{gameday_team_two.id} created"

gameday_players = []
# player_ids.each do |player_id|
#   gameday_players << GamedayPlayer.create!(
#     player_id: player_id,
#     is_present: true,
#     gameday_team_two_id: gameday_team_two.id
#   )
# end

(1..10).each do |player_id|
  gameday_players << GamedayPlayer.create!(
    player_id: player_id,
    is_present: true,
    gameday_team_two_id: gameday_team_two.id
  )
end

p "#{gameday_players.count} gameday_players created"

GenerateGameAssignmentsService.new(gameday_team_two).generate_game_assignments

p "----- GAME 2 PLAYERINNINGS CREATED -----"

# klass = GenerateGameAssignmentsService.new(GamedayTeam.last)
# klass.send(:initial_assignments)
# klass.generate_game_assignments
