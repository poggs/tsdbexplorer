#
#  This file is part of TSDBExplorer.
#
#  TSDBExplorer is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the
#  Free Software Foundation, either version 3 of the License, or (at your
#  option) any later version.
#
#  TSDBExplorer is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
#  Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with TSDBExplorer.  If not, see <http://www.gnu.org/licenses/>.
#
#  $Id$
#


# Check the Redis server hostname and port have been specified

unless $CONFIG['REDIS_SERVER']['hostname'] && $CONFIG['REDIS_SERVER']['port']
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  puts
  puts "No Redis configuration specified - ensure the following lines are included"
  puts "in config/tsdbexplorer.yml:"
  puts
  puts "  REDIS_SERVER:"
  puts "    hostname: redis.example.com"
  puts "    port: 12345"
  puts
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  raise 
end


# Connect to the Redis server

$REDIS = Redis.new(:host => $CONFIG['REDIS_SERVER']['hostname'], :port => $CONFIG['REDIS_SERVER']['port'])


# Ensure we reset the connection if we spawn under Passenger

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      require 'redis'
      $REDIS.cache.reset
    end
  end
end


# Select the correct database so we don't accidentally clobber production
# data if we run unit tests on the production server within the test
# environment!

redis_db = { 'development' => 0, 'test' => 1, 'production' => 2 }

if redis_db.has_key? Rails.env
  $REDIS.select(redis_db[Rails.env])
else
  raise "Cannot select Redis database - unknown Rails environment #{Rails.env}"
end


# Flush the Redis database if we're running in the test environment

$REDIS.flushdb if Rails.env == "test"
