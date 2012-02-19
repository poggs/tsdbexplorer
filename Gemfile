source 'http://rubygems.org'

# Rails and database gems

gem 'rails', '3.2.1'
gem 'rake', '0.9.2.2'
gem 'pg', '>= 0.11.0'


# Asset Pipeline

group :assets do
  gem 'sass-rails', "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
  gem 'json'
  gem 'asset_sync'
end


# Javascript

gem 'jquery-rails'
gem 'execjs'
gem 'therubyracer'


# Application-specific gems

gem 'nokogiri', '>= 1.5.0'
gem 'uuid', '>= 2.3.4'
gem 'amqp', '>= 0.8.3'
gem 'ruby-progressbar', '>= 0.0.10'
gem 'redis', '>= 2.2.2'
gem 'activerecord-import', '>= 0.2.9'
gem 'fastercsv'
gem 'watu_table_builder', :require => 'table_builder'


# Environment-specific gems

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
end

group :development, :test do
  gem "rspec-rails", ">= 2.7.0"
  gem "guard-rspec", ">= 0.5.7"
  gem "rb-inotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "libnotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "growl", :require => false if RUBY_PLATFORM =~ /darwin/i
end
