namespace :db do
  desc "Truncate all tables in the database"
  task truncate_all_tables: :environment do
    puts "Truncating all tables..."

    ActiveRecord::Base.connection.tables.each do |table|
      # Skip tables that Rails uses internally
      next if table == "schema_migrations" || table == "ar_internal_metadata"

      # Execute truncate command
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE;")
    end

    puts "All tables truncated!"
  end

  desc "TRUNCATE all tables and then runs the SEED for inital data"
  task :ts do
    Rake::Task['db:truncate_all_tables'].invoke
    p "----- TRUNCATION COMPLETE -----"

    Rake::Task['db:seed'].invoke
    p "----- SEED COMPLETE -----"
    p "----- COMBINED RAKE TASK COMPLETE -----"
  end
end
