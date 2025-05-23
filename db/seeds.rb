require 'faker'
require 'date'

# THIS SEED IS INTENDED TO CREATE DUMMY TESTABLE DATA
# ONLY FIELDING POSITIONS GENERATION SHOULD EVER BE RAN IN A NON-TEST ENV

# create fielding positions
high_tier_positions = %w[P 1B]
mid_tier_positions = %w[2B SS 3B C]
nil_position = %w[_OUT_]
generic_outfield = %w[OF]
positions = %w[P C 1B 2B SS 3B _OUT_ OF]
# positions = %w[LF LC RC RF P C 1B 2B SS 3B _OUT_ OF]

positions.each do |position|
  rank = case position
  when *high_tier_positions
      1
  when *mid_tier_positions
      2
  when *nil_position
    4
  when *generic_outfield
    5
  else
    99
  end

  FieldingPosition.create!(name: position, hierarchy_rank: rank)
end

# create a team
team = Team.create!(
  name: 'Pirates',
  city: '8U WYBSL Coach Pitch'
)

season = Season.create!(team_id: team.id, name: 'WYBSL Spring 25')

# create thirteen players
# player_ids = []
# (1..13).each do |jersey_num|
#   new_player = Player.create!(
#       first_name: Faker::Name.first_name,
#       last_name: Faker::Name.last_name,
#       jersey_number: jersey_num,
#       team: team
#     )

#   player_ids << new_player.id
# end

player_ids = []
pirate_players = [
  { jersey_number: 1, first_name: "Rory", last_name: "notshowing", team: team },
  { jersey_number: 3, first_name: "Elijah", last_name: "notshowing", team: team },
  { jersey_number: 4, first_name: "Ben", last_name: "notshowing", team: team },
  { jersey_number: 5, first_name: "Luke", last_name: "notshowing", team: team },
  { jersey_number: 6, first_name: "Theo", last_name: "notshowing", team: team },
  { jersey_number: 7, first_name: "Calvin", last_name: "notshowing", team: team },
  { jersey_number: 8, first_name: "Wes", last_name: "notshowing", team: team },
  { jersey_number: 9, first_name: "Owen F", last_name: "notshowing", team: team },
  { jersey_number: 10, first_name: "Owen R", last_name: "notshowing", team: team },
  { jersey_number: 11, first_name: "Mick", last_name: "notshowing", team: team },
  { jersey_number: 12, first_name: "Jax", last_name: "notshowing", team: team },
  { jersey_number: 13, first_name: "Jack", last_name: "notshowing", team: team },
  { jersey_number: 15, first_name: "Mateo", last_name: "notshowing", team: team }
]

pirate_players.each do |player_params|
  player_ids << Player.create!(player_params).id
end

# create a head and asst coach
associated_player_id = Player.find_by_first_name("Calvin").id
Coach.create!(
    first_name: "Vinny",
    last_name: "VanSlyke",
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

#   (1..4).each do |game_num|
#   # game_num = 1
#   game = Game.create!(
#     location: Faker::TvShows::Archer.location,
#     is_home: true,
#     opponent_name: "#{Faker::TvShows::Archer.character}'s whining kids --- GAME #{game_num}",
#     date: Date.new(2024, 3, game_num),
#     season_id: season.id
#   )

#   # create gameday team
#   gameday_team = GamedayTeam.create!(
#     game_id: game.id,
#     team_id: team.id
#   )

#   # # create gameday players
#   gameday_players = []
#   player_ids.each do |player_id|
#     gameday_players << GamedayPlayer.create!(
#       player_id: player_id,
#       is_present: true,
#       gameday_team_id: gameday_team.id
#     )
#   end

#   GameAssignmentsService.new(gameday_team, 6).generate_game_assignments

#   p "----- GAME #{game_num} PLAYERINNINGS CREATED -----"
# end
