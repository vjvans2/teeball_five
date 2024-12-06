module Loggable
  def log_override(invalid_players, override_log, override_counter)
    invalid_players.each do |invalid_player|
      log_message = "OVERRIDE: Player #{invalid_player[:player_id]} not valid for position: #{invalid_player[:position]} due to #{invalid_player[:reason]}"
      override_log << log_message
    end
    override_counter += 1
  end

  def write_overrides_to_log(override_counter, override_log, file_name = "teeball_log.txt")
    File.open(file_name, "a") do |file|
      file.write("TIME ----- #{Time.now.strftime("%B %d, %Y %I:%M %p")}\n") if override_log.size > 0
      override_log.each { |log| file.write(log + "\n") }
      file.write("Final Override Counter ---- #{override_counter}\n") if override_log.size > 0
    end
  end
end
