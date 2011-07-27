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

log = Logger.new(STDOUT)
log.formatter = proc { |severity,datetime,progname,msg| "#{datetime} #{severity}\t#{msg}\n" }

log.info "TSDBExplorer TRUST subscriber starting"

log.info "Connecting to AMQP server #{$CONFIG['AMQP_SERVER']['hostname']} as user #{$CONFIG['AMQP_SERVER']['username']}"

AMQP.start(:host => $CONFIG['AMQP_SERVER']['hostname'], :username => $CONFIG['AMQP_SERVER']['username'], :password => $CONFIG['AMQP_SERVER']['password'], :vhost => $CONFIG['AMQP_SERVER']['vhost']) do |connection|

  log.debug "Connected to AMQP server"

  channel = AMQP::Channel.new(connection)
  queue = channel.queue($CONFIG['AMQP_SERVER']['username'] + ".trust", :durable => true)
  exchange = channel.fanout("tdnet.exch.trust", :durable => true)

  log.debug "Polling for TRUST messages"

  queue.bind(exchange).subscribe do |metadata, payload|

    msg = TSDBExplorer::TDnet::parse_raw_message(payload)

    if msg[:message_type] == "0001"

      log.debug "TRUST activation for #{msg[:train_uid]} running as #{msg[:train_id]}"

      if TSDBExplorer::TDnet::process_trust_activation(msg[:train_uid], msg[:schedule_origin_depart_timestamp].strftime("%Y-%m-%d"), msg[:train_id])
        log.debug "  Activated train #{msg[:train_id]}"
      else
        log.debug "  Failed to activate train"
      end

    elsif msg[:message_type] == "0002"

      log.debug "TRUST cancellation for #{msg[:train_id]}"

      if TSDBExplorer::TDnet::process_trust_cancellation(msg[:train_id], msg[:train_cancellation_timestamp], msg[:cancellation_reason_code])
        log.debug "  Cancelled train #{msg[:train_id]}"
      else
        log.debug "  Failed to cancel train"
      end

    elsif msg[:message_type] == "0003"

      log.debug "TRUST movement message for train #{msg[:current_train_id]}"

      daily_schedule = DailySchedule.find_by_train_identity_unique(msg[:current_train_id])

      if daily_schedule.nil?
        log.warn "  Schedule not found for movement of train #{msg[:current_train_id]}"
        next
      elsif daily_schedule.daily_schedule_locations == []
        log.warn "  Schedule for train #{msg[:train_uid]} is empty!"
        next
      end

      log.debug "  Found train #{msg[:current_train_id]} operated by TOC #{daily_schedule[:atoc_code]}"

      location = Tiploc.find_by_stanox(msg[:location_stanox])

      if location
        log.debug "  Report for #{location.tps_description}"
      else
        log.warn "  Movement report for unknonwn STANOX #{msg[:reporting_stanox]}"
        next
      end
      
      event_type = "unknown"

      if msg[:event_type] == "D"
        event_type = "departed"
      elsif msg[:event_type] == "A"
        event_type = "arrived"
      end

      if msg[:variation_status].blank?
        log.debug "  Train #{event_type} on-time"
      elsif msg[:variation_status] == "L"
        log.debug "  Train #{event_type} #{msg[:timetable_variation].to_i} minutes late"
      elsif msg[:variation_status] == "E"
        log.debug "  Train #{event_type} #{msg[:timetable_variation].to_i} minutes early"
      end

      if msg[:offroute_indicator]
        log.warn "  Train is off-route"
      else
        point = daily_schedule.daily_schedule_locations.where(:tiploc_code => location.tiploc_code).first
      end

      if point

        if msg[:event_type] == "A"
          if point.pass.nil?
            point.actual_arrival = msg[:actual_timestamp]
          else
            point.actual_pass = msg[:actual_timestamp]
          end
        elsif msg[:event_type] == "D"
          if point.pass.nil?
            point.actual_departure = msg[:actual_timestamp]
          else
            point.actual_pass = msg[:actual_timestamp]
          end
        end

        point.actual_platform = msg[:platform] unless msg[:platform].nil?
        point.actual_line = msg[:route] unless msg[:route].nil?
        point.save
      else
        log.warn "  Location #{location.tiploc_code} not found for train #{msg[:current_train_id]}"
      end

    elsif msg[:message_type] == "0004"

      log.debug "TRUST unidentified train report"
      log.debug msg.inspect

    elsif msg[:message_type] == "0005"

      log.debug "TRUST train reinstatement report"
      log.debug msg.inspect

    elsif msg[:message_type] == "0006"

      log.debug "TRUST change of origin report"
      log.debug msg.inspect

    elsif msg[:message_type] == "0007"

      log.debug "TRUST change of identity report"
      log.debug msg.inspect

    elsif msg[:message_type] == "0008"

      log.debug "TRUST change of location report"
      log.debug msg.inspect

    else

      log.warn "Unknown TRUST report type #{msg[:message_type]}"

    end

  end

end
