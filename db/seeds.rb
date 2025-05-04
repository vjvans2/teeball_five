require 'faker'
require 'date'

# THIS SEED IS INTENDED TO CREATE DUMMY TESTABLE DATA
# ONLY FIELDING POSITIONS GENERATION SHOULD EVER BE RAN IN A NON-TEST ENV

# create fielding positions
high_tier_positions = %w[P 1B]
mid_tier_positions = %w[2B SS 3B C]
nil_position = %w[NILL]
generic_outfield = %w[OF]
positions = %w[P C 1B 2B SS 3B NILL OF]
# positions = %w[LF LC RC RF P C 1B 2B SS 3B NILL OF]

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
      3
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
player_ids = []
(1..13).each do |jersey_num|
  new_player = Player.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      jersey_number: jersey_num,
      team: team
    )

  player_ids << new_player.id
end

# create a head and asst coach
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

  # (1..10).each do |game_num|
  game_num = 1
  game = Game.create!(
    location: Faker::TvShows::Archer.location,
    is_home: true,
    opponent_name: "#{Faker::TvShows::Archer.character}'s whining kids --- GAME #{game_num}",
    date: Date.new(2024, 3, game_num),
    season_id: season.id
  )

  # create gameday team
  gameday_team = GamedayTeam.create!(
    game_id: game.id,
    team_id: team.id
  )

  # # create gameday players
  gameday_players = []
  player_ids.each do |player_id|
    gameday_players << GamedayPlayer.create!(
      player_id: player_id,
      is_present: true,
      gameday_team_id: gameday_team.id
    )
  end

  GameAssignmentsService.new(gameday_team, 6).generate_game_assignments

  p "----- GAME #{game_num} PLAYERINNINGS CREATED -----"
