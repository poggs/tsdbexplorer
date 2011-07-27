source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'sqlite3'
gem 'ruby-mysql', '2.9.4', :require => false if RUBY_PLATFORM =~ /darwin/i
gem 'mysql', :require => false if RUBY_PLATFORM =~ /linux/i
gem 'nokogiri', '>= 1.1.4'
gem 'uuid', '>= 2.3.2'
gem 'amqp'
gem 'rake', '0.8.7'

gem 'activerecord-import', '>= 0.2.6'

group :development, :test do
  gem "rspec-rails", ">= 2.5.0"
  gem "rcov", ">= 0.9.9"
  gem "guard-rspec"
  gem "rb-inotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "libnotify", :require => false if RUBY_PLATFORM =~ /linux/i
  gem "rb-fsevent", :require => false if RUBY_PLATFORM =~ /darwin/i
  gem "growl", :require => false if RUBY_PLATFORM =~ /darwin/i
end
