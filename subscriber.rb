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
log.level = 1

log.info "TSDBExplorer TRUST subscriber starting"

['hostname', 'username', 'password', 'vhost'].each do |config_key|
  raise "Missing AMQP_SERVER parameter '#{config_key}' in config/tsdbexplorer.yml" unless $CONFIG['AMQP_SERVER'].has_key? config_key
end

log.info "Connecting to AMQP server #{$CONFIG['AMQP_SERVER']['hostname']} as user #{$CONFIG['AMQP_SERVER']['username']}"

AMQP.start(:host => $CONFIG['AMQP_SERVER']['hostname'], :username => $CONFIG['AMQP_SERVER']['username'], :password => $CONFIG['AMQP_SERVER']['password'], :vhost => $CONFIG['AMQP_SERVER']['vhost']) do |connection|

  log.debug "Connected to AMQP server"

  channel = AMQP::Channel.new(connection)
  queue = channel.queue($CONFIG['AMQP_SERVER']['username'] + ".trust", :durable => true)
  exchange = channel.fanout("tdnet.exch.trust", :durable => true)

  log.debug "Polling for TRUST messages"

  queue.bind(exchange).subscribe do |metadata, payload|

    msg = TSDBExplorer::TDnet::process_trust_message(payload)

    if msg.status == :ok
      log.debug msg.message
    else
      log.warn msg.message
    end

  end

end
