class TeamService
  attr_reader :team
  def initialize(team_id)
    @team = Team.find(team_id)
  end

  def generate_team_report
    report = []

    team.players.sort_by(&:jersey_number).each do |player|
      player_report = player.player_innings
        .group_by { |pi| pi.fielding_position.name }
        .map { |position, innings| { position:, count: innings.size } }
        .sort_by { |s| FieldingPosition.find_by_name(s[:position]) }

      report << {
        name: player.full_name,
        jersey_number: player[:jersey_number],
        player_report: {
          games_played: player.player_innings.map(&:game_id).uniq.size,
          pitcher: position_report(player_report, "P"),
          catcher: position_report(player_report, "C"),
          first_base: position_report(player_report, "1B"),
          second_base: position_report(player_report, "2B"),
          shortshop: position_report(player_report, "SS"),
          third_base: position_report(player_report, "3B"),
          outfield: position_report(player_report, "OF"),
          out: position_report(player_report, "_OUT_")
        }
      }
    end

    report
  end

  private

  def position_report(player_report, position)
    position = player_report.filter { |r| r[:position] == position }
    if position.empty?
      0
    else
      position.first[:count]
    end
  end
end
