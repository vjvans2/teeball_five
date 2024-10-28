# lib/tasks/setup.rake
namespace :project do
  desc "Set up the project for new contributors"
  task setup: :environment do
    puts "Running setup for the project..."

    # 1. Install gem dependencies
    puts "Installing dependencies..."
    system("bundle install")

    # 2. Set up the database
    puts "Setting up the database..."
    system("rails db:create")
    system("rails db:migrate")
    system("rails db:seed")

    puts "Project setup complete!"
  end
end
