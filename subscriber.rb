#!/usr/bin/env ruby
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
log.level = 1

log.info "Starting TSDBExplorer AMQP subscriber"

['hostname', 'username', 'password', 'vhost'].each do |config_key|
  raise "Missing AMQP_SERVER parameter '#{config_key}' in config/tsdbexplorer.yml" unless $CONFIG['AMQP_SERVER'].has_key? config_key
end


# Set up log files for each feed

trust_logger = Logger.new('trust.log', 'daily')
trust_logger.level = Logger::DEBUG

td_logger = Logger.new('td.log', 'daily')
td_logger.level = Logger::DEBUG

vstp_logger = Logger.new('vstp.log', 'daily')
vstp_logger.level = Logger::DEBUG

tsr_logger = Logger.new('tsr.log', 'daily')
tsr_logger.level = Logger::DEBUG


# Connect to the AMQP server

amqp_config = $CONFIG['AMQP_SERVER']

log.info "Connecting to AMQP server as amqp://#{amqp_config['username']}@#{amqp_config['hostname']}/"

EventMachine.run do

  AMQP.connect(:host => amqp_config['hostname'], :username => amqp_config['username'], :password => amqp_config['password'], :vhost => amqp_config['vhost']) do |connection|

    log.info "Connected to #{amqp_config['hostname']}"    

    channel = AMQP::Channel.new(connection)

    trust_exchange = channel.fanout('tdnet.exch.trust', :durable => true)
    channel.queue(amqp_config['username'] + ".trust", :durable => true).bind(trust_exchange).subscribe do |payload|

      trust_logger.debug payload

      trust_message = TSDBExplorer::TDnet::process_trust_message(payload)

      if trust_message.status == :ok
        log.debug trust_message.message
      else
        log.warn trust_message.message
      end

      $REDIS.incr('STATS:TRUST:PROCESSED')
      $REDIS.set('STATS:TRUST:UPDATE', Time.now.to_i)

    end

    vstp_exchange = channel.fanout('tdnet.exch.vstp', :durable => true)
    channel.queue(amqp_config['username'] + ".vstp", :durable => true).bind(vstp_exchange).subscribe do |payload|

      vstp_logger.debug payload

      begin

        vstp_message = TSDBExplorer::TDnet::process_vstp_message(payload)

        if vstp_message.status == :ok
          log.debug vstp_message.message
        else
          log.warn vstp_message.message
        end

        $REDIS.incr('STATS:VSTP:PROCESSED')
        $REDIS.set('STATS:VSTP:UPDATE', Time.now.to_i)

      rescue

        log.debug "Failed to parse a VSTP message"

      end

    end

    tsr_exchange = channel.fanout('tdnet.exch.tsr', :durable => true)
    channel.queue(amqp_config['username'] + ".tsr", :durable => true).bind(tsr_exchange).subscribe do |payload|

      tsr_logger.debug payload

      $REDIS.incr('STATS:TSR:PROCESSED')
      $REDIS.set('STATS:TSR:UPDATE', Time.now.to_i)

    end

    td_exchange = channel.fanout('tdnet.exch.td', :durable => true)
    channel.queue(amqp_config['username'] + ".td", :durable => true).bind(td_exchange).subscribe do |payload|

      td_logger.debug payload

      td_message = TSDBExplorer::TDnet::process_smart_message(payload)

      if td_message.status == :ok
        log.debug td_message.message
      else
        log.warn td_message.message
      end

      $REDIS.incr('STATS:TD:PROCESSED')
      $REDIS.set('STATS:TD:UPDATE', Time.now.to_i)

    end

  end

end
