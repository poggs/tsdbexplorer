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

require 'spec_helper'

describe "lib/tsdbexplorer/realtime.rb" do

  before(:each) do
    $REDIS.flushdb
  end

  it "should put the site in to maintenance mode" do
    $REDIS.get('OTT:SYSTEM:MAINT').should be_nil
    TSDBExplorer::Realtime::set_maintenance_mode('Test message')
    $REDIS.get('OTT:SYSTEM:MAINT').should eql('Test message')
  end

  it "should take the site out of maintenance mode" do
    $REDIS.get('OTT:SYSTEM:MAINT').should be_nil
    TSDBExplorer::Realtime::set_maintenance_mode('Test message')
    TSDBExplorer::Realtime::clear_maintenance_mode
    $REDIS.get('OTT:SYSTEM:MAINT').should be_nil
  end

end
