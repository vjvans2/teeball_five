module Loggable
  def log_override(invalid_players)
    invalid_players.each do |invalid_player|
      log_message = "OVERRIDE: Player #{invalid_player[:player_id]} not valid for position: #{invalid_player[:position]} due to #{invalid_player[:reason]}"
      @override_log << log_message
    end
    @override_counter += 1
  end

  def write_overrides_to_log(override_counter, override_log)
    File.open("teeball_log.txt", "a") do |file|
      file.write("TIME ----- #{Time.now.strftime("%B %d, %Y %I:%M %p")}\n")
      override_log.each { |log| file.write(log + "\n") }
      file.write("Final Override Counter ---- #{override_counter}\n")
    end
  end
end
