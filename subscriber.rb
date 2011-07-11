#!/usr/bin/ruby
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

require File.expand_path(File.dirname(__FILE__) + "/config/environment")

require 'rubygems'
require 'amqp'

puts "#{Time.now} TSDBExplorer subscriber starting"

AMQP.start(:host => $CONFIG['AMQP_SERVER']['hostname'], :username => $CONFIG['AMQP_SERVER']['username'], :password => $CONFIG['AMQP_SERVER']['password'], :vhost => $CONFIG['AMQP_SERVER']['vhost']) do |connection|

  channel = AMQP::Channel.new(connection)
  queue = channel.queue($CONFIG['AMQP_SERVER']['username'] + ".trust", :durable => true)
  exchange = channel.fanout("tdnet.exch.trust", :durable => true)

  puts "#{Time.now} Polling for TRUST messages"

  queue.bind(exchange).subscribe do |metadata, payload|

    msg = TSDBExplorer::TDnet::parse_raw_message(payload)

    if msg[:message_type] == "0001"

      puts "#{Time.now} TRUST Activation for #{msg[:train_id]} *** NOT YET SUPPORTED ***"

      daily_schedule = DailySchedule.find_by_train_identity_unique(msg[:train_id])

      if daily_schedule.nil?
        puts "#{Time.now}   Schedule not found"
        next
      end

      daily_schedule.activated = msg[:train_creation_timestamp]

      puts "#{Time.now}   Schedule found - operated by #{daily_schedule[:atoc_code]}"

    elsif msg[:message_type] == "0002"

      puts "#{Time.now} TRUST Cancellation"

      puts msg.inspect

    elsif msg[:message_type] == "0003"

      puts "#{Time.now} TRUST Movement message for train #{msg[:current_train_id]}"

      daily_schedule = DailySchedule.find_by_train_identity_unique(msg[:current_train_id])

      if daily_schedule.nil?
        puts "#{Time.now}   Schedule not found"
        next
      end

      puts "#{Time.now}   Found train #{daily_schedule[:train_identity]} operated by TOC #{msg[:toc_id]}"

      location = Tiploc.find_by_stanox(msg[:location_stanox])

      if location
        puts "#{Time.now}   Report for #{location.tps_description}"
      else
        puts "#{Time.now}   Report for unknonwn STANOX #{msg[:reporting_stanox]}"
        next
      end
      
      event_type = "unknown"

      if msg[:event_type] == "D"
        event_type = "departed"
      elsif msg[:event_type] == "A"
        event_type = "arrived"
      end

      if msg[:variation_status].blank?
        puts "#{Time.now}   Train #{event_type} on-time"
      elsif msg[:variation_status] == "L"
        puts "#{Time.now}   Train #{event_type} #{msg[:timetable_variation].to_i} minutes late"
      elsif msg[:variation_status] == "E"
        puts "#{Time.now}   Train #{event_type} #{msg[:timetable_variation].to_i} minutes early"
      end

      point = daily_schedule.daily_schedule_locations.where(:tiploc_code => location.tiploc_code).first

      if point
        point.actual_arrival = msg[:actual_timestamp] if msg[:event_type] == "A"
        point.actual_departure = msg[:actual_timestamp] if msg[:event_type] == "D"
        point.save
      else
        puts "#{Time.now}   Location #{location.tiploc_code} not found in schedule"
      end

    elsif msg[:message_type] == "0004"
      puts "TRUST Undefined Train"
    elsif msg[:message_type] == "0005"
      puts "TRUST Train Reinstatement"
    elsif msg[:message_type] == "0006"
      puts "TRUST Change Of Origin"
    elsif msg[:message_type] == "0007"
      puts "TRUST Change of Identity"
    elsif msg[:message_type] == "0008"
      puts "TRUST Change of Location"
    else
      puts "Unknown message type #{msg[:message_type]}"
    end

  end

end
