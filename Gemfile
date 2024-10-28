source "https://rubygems.org"

gem "rails", "~> 7.2.1"
gem "sprockets-rails"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "faker"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "annotaterb"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "factory_bot_rails"
  gem "database_cleaner-active_record"
end
