source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby " 3.3.6"

gem "rails", "~> 7.0.8", ">= 7.0.8.4"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem 'rack-cors'
gem 'devise'
gem 'devise-jwt'
gem 'jsonapi-serializer'

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails'
  gem 'rspec-rails'
end
gem 'factory_bot_rails'


group :test do
  gem 'shoulda-matchers'
  gem 'faker'
end


gem "pundit", "~> 2.4"
gem 'simplecov', require: false, group: :test
gem 'stripe'