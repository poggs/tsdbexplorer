source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'pg'
gem 'nokogiri', '>= 1.1.4'
gem 'uuid', '>= 2.3.2'
gem 'amqp'
gem 'rake', '0.9.2'
gem 'ruby-progressbar', '>= 0.0.10'
gem 'memcache', '>= 1.2.13'

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
end

gem 'activerecord-import', '>= 0.2.6'

group :development, :test do
  gem "rspec-rails", ">= 2.7.0"
  gem "rcov", ">= 0.9.9"
  gem "guard-rspec"
  gem "rb-inotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "libnotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "growl", :require => false if RUBY_PLATFORM =~ /darwin/i
end
